/**
 * //Nested closures:
 * def clout(k):
 *     closv1 = k
 *     def clin():
 *         closv2 = 2
 *         def inn():
 *            closv2 += closv1
 *            closv1 += 1
 *            return closv2
 *         return inn
 *     return clin
 * fun = clout(2)()
 * print(fun(), fun()) //output: 4 7
 *
 */
public class NestedClosures{
	
	//direct method with closure
	public static clout$0.clin$0 clout(int k){
			return new clout$0().call(k);
	}
	//method closure: implementation
	public static class clout$0{
			//closure variable(s)
			int closv1;

			//implementation of closure method
			public clin$0 call(int k){
				closv1 = k;
				return new clin$0();
			}

			//direct method with closure
			public clin$0.inn clin(){
					return new clin$0().call();
			}
			public class clin$0{
					//closure variable(s)
					int closv2;

					//implementation of closure method
					public inn call(){
							closv2 = 2;
							return new inn();
					}

					//direct method without closure variables
					public int inn(){
							closv2 += closv1;
							closv1 += 1;
							return closv2;
					}
					public class inn{ //wrapper of all signatures
							public int call(){
									return inn();
							}
					}
			}
			public class clin{ //wrapper of all signatures
					public final clin$0.inn call(){
							return clin();
					}
			}
	}
	public static class clout{//wrapper of all signatures
			public static clout$0.clin$0 call(int k){
					return clout(k);
			}
	}

	public static void main(String argv[]){
			clout$0.clin$0.inn fun = clout(2).call();
			System.out.println(fun.call()+" "+ fun.call());
	}
}
