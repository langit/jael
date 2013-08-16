/**
 * dynamic compilation := implicit functor template
 * 			+ dynamic type inference;
 *
 * things to show: 
 * functor and class as primary objects;
 * closure support;
 * lambda function;
 * default arguments (book keeping by compiler);
 * keyword arguments (book keeping by compiler);
 * type-augmented tuples (each position has a given type):
 * 		a: used for returning multiple values in functors;
 * 		b: used for passing arguments to functors (*args);
 * how to create such a thing implicitly?
 * 		def funct(a, *args): 
 * 			a(*args);
 * 		;
 * 		funct(put, 1); //implicitly specifies types for *args 
 * 		funct(invoke, "a", 3); //another example
 * In implementation, the *args implies variable length
 * of arguments, therefore funct has the following actual
 * versions:
 * 		void funct(put a, int args$0); //args=[args$0]
 *		//where as below: args=[args$0, args$1]
 * 		void funct(invoke a, String	args$0, int args$1);
 * another way of creating type-augmented tuples:
 * 		t = 1, "b", 3.0; 
 * 		//int t$0=1; String t$1="b"; float t$2=3.0
 * Thus, all type-augmented tuples are "faked" that way ;)
 * We will support args[i] (i being a constant), 
 * *args, and args; where args is an Object[];
 * NOTE: we don't need to support **keywords like Python,
 * as all keyword arguments are conveted into positional
 * arguments at compile time; a decorator is defined like:
 * 		def decorator(fun):
 * 			//"*args" specify multiple args
 *			//":" specify types and defaults
 *			//"fun.args" denotes the types/defaults of its args  
 * 			def workhorse(*args : fun.args):
 * 				return fun(*args);
 * 			;
 * 			return workhorse;
 * 		;
 * 
 * Other features:
 * 1: comprehensions (generator expression)
 * 		Here is an idea: generator is a java iterator<T>
 * 		template with a type parameter T:
 * 		For example: range [a:b] may be done like this:
 * 		class range implements Collection<int>{
 * 			int a, b, step;
 * 			public range(int a, int b, int step){
 * 				this.a=a; this.b=b; this.step=step;
 * 				this.v = b;
 * 			}
 * 			public iterator<int> iterate(){
 * 			  return new iterator<int>{
 * 				int v;
 * 				void start(){ v = a - step; }
 * 				boolean hasNext(){ return step>0?b<=v:b>=v; }
 * 				int next(){ v += step; return v; }
 * 			  }
 * 			}
 * 		}
 *
 * 		Translate 
 * 			a = [t*t for t in [:9]];
 * 		into equivalent jael code, which can be 
 * 		further translated into java:
 * 			a = listcom<Integer>(lambda t: t*t, range(9)); 
 * 		where listcom is a generic function from 
 * 		the built-in library:
 *
 * 			def listcom<T>(expr, items):
 * 				ret = list<T>();
 * 				for i in items: 
 * 					ret.append(expr(i));
 * 				;
 * 				return ret;
 * 			;
 *
 * 		A direct way of comprehension by java local class:
 *		first declare an interface somewhere in the functor:
 *			interface $compr0${List<Integer> go();}
 *		then implement it using anonymous class:
 *			List<Integer> c = new $compr0$(){
 *				List<Integer> call(){
 *					List<Integer> c = new ArrayList<Integer>();
 *					for(Integer i: new range(9)){ c.append(i*i); }
 *					return c;
 *				}
 *			}.call();
 *						
 * 2: a if b else c (--> java ternary operator)
 * 3: alt x:
 *    	case 'a':
 *    	case 'b':
 *    ;
 *

def put(a):
	print(a);
;

def invoke(f, b, t):
	f(b);
	if t > 0: 
		invoke(f,b,t-1);
	;
;

//the code below indicates that 
//1: f is a callable
//2: f maybe called with no param
//3: f maybe called with one param
//it does not fit into the demo, DISCARDED
def invoke(f, t=null):
	if t==null: f();
	else: f(t);
;

//instead, define two versions
def invoke(f, t): 
	f(t);
;
def invoke(f): 
	f();
;

//closure
def closure(a):
	t = a*a;
	def inc():
		t += a;
		a += 1;
		return t;
	def dec():
		t -= a;
		a -= 1;
		return t;
	return inc, dec;
;

class test:
	a:int;
	b:str;

	def test(a, b): //constructor
		.a = a;
		.b = b;
	;

	def show():
		invoke(put, .b, .a);
	;

	def.say(): //static method
		put("hello test!");
	;
;

def.main(args):
	invoke(put, "abc", 3);
	invoke(put, 123, 3);
	t = test(3, "ABC");
	t.show();
	invoke(t.show);
	t.say();
	invoke(t.say); //or: invoke(test.say)
	test.say.call();

	inc, dec = closure();
	put(inc()); put(inc());
	put(dec()); put(dec());

	invoke(lambda f: f(), test.say);
	
	// Next, we do "curry" or "partial application".
	g = invoke{invoke}; //curry type, g:invoke{invoke}
    g(test.say);
	h = invoke{t=3}; //type: invoke{t:int}
	h(put, "curry!"); //invoke(put, "curry!", t=3);
	h(put); //invoke(put, t=3);
;

 */
class BetterTrans{ //module level, every member is static
	public static final void put(int b){
			System.out.println(b); 
	}
	static public class put {//implements inspection
		public final void call(int b){
			System.out.println(b); 
		}
		public final void call(String b){
			System.out.println(b); 
		}
	}
	static final put put=new put();

	/**
	 * the way to support static fields for instance class:
	 * create a static companion class that holds the static
	 * fields, so that all reference to the static fields
	 * are pointing to the static fields in the companion class.
	 */ 

	/**
	 * We can have static methods 
	 * which the method class may forward the call.
	 */
	static public void invoke() { }

	static public class invoke { //implements jael.callable
			//support default values by [static]? final fields
			//how about by a final instance fields?
			//sometimes default values differ
			//e.g.: def functions in a for loop.
			//let all *local functs* do it by instance field,
			//default values are then provided to constructor
			static final int $t = 0; //default value for t
			static final int $b = 0; //default value for t
			public final void call(put f, int b, int t){
					f.call(b);
					if (t>1) invoke.call(f, b, t-1);
			}
			public final void call(put f, String b, int t){
					f.call(b);
					if (t>1) invoke.call(f, b, t-1);
			}
			public final void call(test.show f){
					f.call();
			}
			public final void call(test.say f){
					f.call();
			}
			public final void call(main.$0 f, test.say s){
					f.call(s);
			}

			/**
			 * the curry class providing default impl
			 * for all possible calling patterns.
			 */
			public static class curry$0{
				final invoke f;
				curry$0(invoke $f$){
						f = $f$;
				}
				public final void call(test.say s){
					//we have the options of either
					//to call a version of the call
					//method defined by the outer class
					//like this: invoke.call(...);
					//Or we may generate the code here
					//directly:
					f.call(s); //direct code generation
				}
			}

			public final curry$0 curry(final invoke f){
					return new curry$0(f);
			}

			/**
			 * to support keyword currying, 
			 * we don't need extra dummy interfaces,
			 * as with **kwds argument;
			 * the curry class itself marks the difference;
			 *
			 * NOTE: *args, **kwds are special forms of
			 * arguments, they are different from
			 * plain arrays and disctionaries.
			 */
			public static class curry$1{
				final int t;
				curry$1(int $t$){
						t = $t$;
				}
				public final void call(put f, String b){
						invoke.call(f, b, t); //indirect
				}
				public final void call(put f){
						f.call(t); //direct
				}
			}

			public final curry$1 curry(final int t){
					return new curry$1(t);
			}
	}
	public static final invoke invoke = new invoke();

	public static class closure$0${
				int a;
				int t;
				private closure$0$(){}

				public int inc(){
						a += 1;
						t += a;
						return t;
				}
				public class inc{
						public final int call(){
								return inc();
						}
				}

				public int dec(){
						t -= a;
						a -= 1;
						return t;
				}
				public class dec{
						public final int call(){
								return dec();
						}
				}

				final Object[] call(int $a$){
						a = $a$; //explicitly init closure param
						t = a*a; //implicitly init closure param
						inc inc = new inc();//def inc
						dec dec = new dec();//def dec
						return new Object[]{inc, dec};
				}
	}

	public static Object[] closure(int a){
					return new closure$0$().call(a);
	}

	public static class closure {
			public final Object[] call(int a){
					return closure(a);
			}
	}

	public final static closure closure = new closure();

	//to be passed as a class reference
	static final test.$class$ test = new test.$class$();

	public static test test() { return new test(); }
	public static test test(int a, String b){
			return new test(a,b);
	}

	public static class test {
			public int a;
			public String b;

			public static class say{
					public final void call(){
						put.call("hello test!");
					}
			}
			public static void say(){
					test.say.call();//instance 'test'
			}

			public test(){
					this.a = 2;
					this.b = "default";
			}

			public test(int a, String b){
					this.a = a;
					this.b = b;
			}

			public void show(){//direct method call
					invoke.call(put, this.b, this.a);
			}
			public class show{//method ref: new show()
				public void call(){ show(); }
			}
			//alternatively, use java property for lazy init
			private show show = null;
			public show getShow(){
					if(show==null) show = new show();
					return show;
			}//view 'show' as a property

		public static class $class$ {
			public static test call(int a, String b){
					return new test(a,b);
			}
			public static final say say = new say();
		}

	}

	public static class subtest extends test {
	}

	public static class main{

		public static class $0 { //lambda function
				public final void call( test.say f){
						f.call();
				}
		}

		public final void call(String[] args){
			int call = 0;
			invoke.call(put, "A", 3);
			invoke.call(put, 123, 3);
			test t = test.call(3, "ABC"); //constructor
			t.show(); //direct instance method invocation
			invoke.call(t.new show()); //pass method as param
			t.say(); //direct static method invocation
			invoke.call(test.say); //t.say --> test.say
			test.say.call(); //invoke static method

			Object[] $list$ = closure.call(0);
			closure$0$.inc inc = (closure$0$.inc) $list$[0];
			closure$0$.dec dec = (closure$0$.dec) $list$[1];

			put.call(inc.call()); 
			put.call(inc.call());
			put.call(dec.call()); 
			put.call(dec.call());
			put(2345678);

			invoke.call(new $0(), test.say);
			invoke.curry$0 g = invoke.curry(invoke);
			put.call("OK, curry: \n");
			g.call(test.say);
			invoke.curry$1 h = invoke.curry(3);
			h.call(put, "curry!");
			h.call(put);
		}
	}

	public static final main main = new main();
	public static void main(String[] args){
			main.call(args);
			new subtest().show();
			//put.call(3>4?"true":"false");
	}

	public static class decorator{
			public final workhorse$0 call(invoke f){
					return new workhorse$0(f);
			}
			public static class workhorse$0{
					private invoke f;
					workhorse$0(invoke f){this.f = f;}
					public void call(test.say s){
							f.call(s);
					}
			}
	}
	public static final decorator decorator = new decorator();

}
