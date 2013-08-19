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
 * print(fun(), fun()) //4 7
 *
 */
public class NestedClosures{
	
	public static clout$0.clin$0 clout(int k){
			return new clout$0().call(k);
	}
	public static class clout$0{
			int closv1;

			public clin$0 call(int k){
				closv1 = k;
				return new clin$0();
			}

			public clin$0.inn$0 clin(){
					return new clin$0().call();
			}
			public class clin$0{
					int closv2;
					public inn$0 call(){
							closv2 = 2;
							return new inn$0();
					}

					public int inn(){
							closv2 += closv1;
							closv1 += 1;
							return closv2;
					}
					public class inn$0{
							public int call(){
									return inn();
							}
					}
			}
	}
	public static void main(String argv[]){
			clout$0.clin$0.inn$0 fun = clout(2).call();
			System.out.println(fun.call()+" "+ fun.call());
	}
}
