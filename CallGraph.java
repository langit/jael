import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.misc.MultiMap;
import org.antlr.v4.runtime.misc.OrderedHashSet;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.ParseTreeWalker;
//import org.stringtemplate.v4.ST;

import java.io.FileInputStream;
import java.io.InputStream;
import java.util.Set;

public class CallGraph {
    public static void main(String[] args) throws Exception {
        String inputFile = null;
        if ( args.length>0 ) inputFile = args[0];
        InputStream is = System.in;
        if ( inputFile!=null ) {
            is = new FileInputStream(inputFile);
        }
        ANTLRInputStream input = new ANTLRInputStream(is);
        JaelLexer lexer = new JaelLexer(input);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        JaelParser parser = new JaelParser(tokens);
        parser.setBuildParseTree(true);
        ParseTree tree = parser.module();
        // show tree in text form
        System.out.println(tree.toStringTree(parser));

        //ParseTreeWalker walker = new ParseTreeWalker();
        //FunctionListener collector = new FunctionListener();
        //walker.walk(collector, tree);
        //System.out.println(collector.graph.toString());
        //System.out.println(collector.graph.toDOT());

        // Here's another example that uses StringTemplate to generate output
//        System.out.println(collector.graph.toST().render());
    }
}
