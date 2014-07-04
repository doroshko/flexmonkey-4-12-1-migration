/*
 * FlexMonkey 1.0, Copyright 2008, 2009, 2010 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.
 */
package com.gorillalogic.flexmonkey.xmlConversion {

    import com.gorillalogic.flexmonkey.core.MonkeyNode;
    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.core.MonkeyTestSuite;

    import flash.events.IEventDispatcher;

    import mx.collections.ArrayCollection;
    import com.gorillalogic.utils.FMStringUtil;

    public class TestXMLConvertor {

        public function generateXML(input:ArrayCollection, useMultipleFiles:Boolean):Object {
            var tsXML:XML = <FlexMonkey></FlexMonkey>;
            var t:Object;
            XML.prettyPrinting = true;
            var data:Object = {
                    rootFile: "",
                    suiteFiles: []
                };

            if (useMultipleFiles) {
                var filesnames:ArrayCollection = new ArrayCollection();
                var count:int = 0;

                for each (t in input) {
                    var filePrefix:String = FMStringUtil.testNameToClassName(t.name);
                    var filename:String = filePrefix;
                    filename += (filesnames.contains(filePrefix)) ? "_" + count + ".xml" : ".xml";
                    filesnames.addItem(filePrefix);

                    var suiteXml:XML = <FlexMonkey></FlexMonkey>;
                    suiteXml.appendChild(XmlConversionFactory.encode(t));
                    tsXML.appendChild(<TestSuiteFile filename={filename} />);

                    data.suiteFiles[count] = {
                            filename: filename,
                            xml: suiteXml.toXMLString()
                        };

                    count++;
                }
            } else {
                for each (t in input) {
                    tsXML.appendChild(XmlConversionFactory.encode(t));
                }
            }

            data.rootFile = tsXML.toXMLString();
            return data;
        }

        public function parseXML(input:XML):ArrayCollection {
            var c:ArrayCollection = new ArrayCollection();
            parseXMLChildren(input.elements(), c);
            return c;
        }

        private function parseXMLChildren(testNodes:XMLList, col:ArrayCollection, parent:MonkeyNode = null):void {
            for each (var x:XML in testNodes) {
                var node:Object = XmlConversionFactory.decode(x);

                if (node is MonkeyNode) {
                    var monkeyNode:MonkeyNode = node as MonkeyNode;

                    if (parent != null) {
                        monkeyNode.parent = parent;
                    } else {
                        monkeyNode.parent = monkeyNode;
                    }

                    // parse children nodes
                    monkeyNode.children = new ArrayCollection();
                    parseXMLChildren(x.elements(), monkeyNode.children, monkeyNode);

                    // add node to collection
                    col.addItem(monkeyNode);
                } else if (node is MonkeyRunnable) {
                    node.parent = parent;
                    parent.children.addItem(node)
                }
            }
        }

    }
}