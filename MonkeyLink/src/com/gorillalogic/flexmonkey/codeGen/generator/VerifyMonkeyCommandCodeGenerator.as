/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.codeGen.generator {

    import com.gorillalogic.flexmonkey.codeGen.IMonkeyCommandCodeGenerator;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
    import com.gorillalogic.flexmonkey.vo.AttributeVO;
    import com.gorillalogic.utils.FMStringUtil;

    public class VerifyMonkeyCommandCodeGenerator implements IMonkeyCommandCodeGenerator {

		private static const importStr:String = "    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;\n";
		private static const arrayCollectionImportStr:String = "    import mx.collections.ArrayCollection;\n";
		private static const attributeVOImportStr:String = "    import com.gorillalogic.flexmonkey.vo.AttributeVO;\n";
		
        protected function getProperties(verify:VerifyMonkeyCommand, cmdImports:Array):Array {
            var a:Array = [
                FMStringUtil.formatForOutput(verify.description),
                (verify.verifyBitmap ? FMStringUtil.formatForOutput(verify.snapshotURL) : "null"),
                FMStringUtil.formatForOutput(verify.value),
                FMStringUtil.formatForOutput(verify.prop),
                FMStringUtil.formatForOutput(verify.verifyBitmap)
                ];

            var attr:String = FMStringUtil.formatForOutput(null);

            if (verify.attributes.length != 0) {
				if (cmdImports.indexOf(arrayCollectionImportStr) == -1) {
					cmdImports.push(arrayCollectionImportStr);
				}
				
				if (cmdImports.indexOf(attributeVOImportStr) == -1) {
					cmdImports.push(attributeVOImportStr);	
				}
				
                var separator:String = "";
                attr = "\n                    new ArrayCollection([";
                for each (var attribute:AttributeVO in verify.attributes) {
                    attr += separator + "\n";
                    attr += "                        new AttributeVO("
                        + FMStringUtil.formatForOutput(attribute.name) + ", "
                        + FMStringUtil.formatForOutput(attribute.namespaceURI) + ", "
                        + FMStringUtil.formatForOutput(attribute.type) + ", "
                        + FMStringUtil.formatForOutput(attribute.expectedValue.split("\n").join("\\n"))
                        + ")";
                    separator = ",";
                }
                attr += "\n                    ])";
            }
            a.push(attr);


            if (!FMStringUtil.isEmpty(verify.containerValue)) {
                a.push(FMStringUtil.formatForOutput(verify.containerValue));
            } else {
                a.push(FMStringUtil.formatForOutput(null));
            }

            if (!FMStringUtil.isEmpty(verify.containerProp)) {
                a.push(FMStringUtil.formatForOutput(verify.containerProp));
            } else {
                a.push(FMStringUtil.formatForOutput(null))
            }

            a.push(FMStringUtil.formatForOutput(verify.isRetryable));
            a.push(FMStringUtil.formatForOutput(verify.delay));
            a.push(FMStringUtil.formatForOutput(verify.attempts));
            a.push(verify.verifyBitmapFuzziness.toString());

            return a;
        }

        public function getAS3(cmd:Object, cmdImports:Array):String {
			if (cmdImports.indexOf(importStr) == -1) {
				cmdImports.push(importStr);
			}
			
            var verify:VerifyMonkeyCommand = cmd as VerifyMonkeyCommand;
            var a:Array = getProperties(verify, cmdImports);
            return 'new VerifyMonkeyCommand(' + a.join(', ') + ')';
        }
    }
}