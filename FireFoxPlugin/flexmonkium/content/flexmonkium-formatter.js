/*** derived from: formatCommandOnlyAdapter.js ***/
function parse(testCase, source) {
	testCase.header = null;
	testCase.footer = null;
	var commands = [];

	var reader = new LineReader(source);
	var line;
	while ((line = reader.read()) != null) {
		commands.push(new Line(line));
	}
	testCase.commands = commands;
	testCase.formatLocal(this.name).header = "";
	testCase.formatLocal(this.name).footer = "";
	testCase.formatLocal(this.name).frozenHeaderAndFooter = true;
}

function format(testCase, name, saveHeaderAndFooter) {
	this.log.info("formatting testCase: " + name);
	var result = '';
	var header = "";
	var footer = "";
	this.commandCharIndex = 0;
	var frozen = testCase.formatLocal(this.name).frozenHeaderAndFooter;
	if (frozen) {
		header = testCase.formatLocal(this.name).header;
		footer = testCase.formatLocal(this.name).footer;
	} else if (this.formatHeader) {
		header = formatHeader(testCase);
	}
	result += header;
	this.commandCharIndex = header.length;
	testCase.formatLocal(this.name).header = header;
	result += formatCommands(testCase.commands);
	if (!frozen && this.formatFooter) {
		footer = formatFooter(testCase);
	}
	result += footer;
	testCase.formatLocal(this.name).footer = footer;
	if (saveHeaderAndFooter) {
		testCase.formatLocal(this.name).frozenHeaderAndFooter = true;
	}
	return result;
}

function filterForRemoteControl(originalCommands) {
	if (this.remoteControl) {
		var commands = [];
		for (var i = 0; i < originalCommands.length; i++) {
			var c = originalCommands[i];
			if (c.type == 'command' && c.command.match(/AndWait$/)) {
				var c1 = c.createCopy();
				c1.command = c.command.replace(/AndWait$/, '');
				commands.push(c1);
				commands.push(new Command("waitForPageToLoad", options.timeout));
			} else {
				commands.push(c);
			}
		}
		if (this.postFilter) {
			// formats can inject command list post-processing here
			commands = this.postFilter(commands);
		}
		return commands;
	} else {
		return originalCommands;
	}
}

function addIndent(lines) {
	return lines.replace(/.+/mg, function(str) {
			return indent() + str;
		});
}

function formatCommands(commands) {
	commands = filterForRemoteControl(commands);
	if (this.lastIndent == null) {
		this.lastIndent = '';
	}
	var result = '';
	for (var i = 0; i < commands.length; i++) {
		var line = null;
		var command = commands[i];
		if (command.type == 'line') {
			line = command.line;
		} else if (command.type == 'command') {
			line = formatCommand(command);
			if (line != null) line = addIndent(line);
			command.line = line;
		} else if (command.type == 'comment' && this.formatComment) {
			line = formatComment(command);
			if (line != null) line = addIndent(line);
			command.line = line;
		}
		command.charIndex = this.commandCharIndex;
		if (line != null) {
			updateIndent(line);
			line = line + "\n";
			result += line;
			this.commandCharIndex += line.length;
		}
	}
	return result;
}

function updateIndent(line) {
	var r = /^(\s*)/.exec(line);
	if (r) {
		this.lastIndent = r[1];
	}
}

function indent() {
	return this.lastIndent || '';
}


/*** derived from: remoteControl.js ***/
function formatHeader(testCase) {
var className = testCase.getTitle();
	if (!className) { className = "MyTest"; }

	var baseURL = testCase.baseURL;
	if (!baseURL) { baseURL = "http://path-to-your-site/"; }

	var methodName = 'myTestMethod';

	var header = options.header.
		replace(/\$\{className\}/g, className).
		replace(/\$\{methodName\}/g, methodName).
		replace(/\$\{baseURL\}/g, baseURL).
		replace(/\s*extends\s*\$\{superClass\}/g, (options.superClass.length > 0 ? ' extends ' + options.superClass : '')).
		replace(/\$\{([a-zA-Z0-9_]+)\}/g, function(str, name) { return (name in options ? options[name] : str); });

	this.lastIndent = indents(parseInt(options.initialIndents));

	var formatLocal = testCase.formatLocal(this.name);
	formatLocal.header = header;
	return formatLocal.header;
}

function formatFooter(testCase) {
	var formatLocal = testCase.formatLocal(this.name);
	formatLocal.footer = options.footer;
	return formatLocal.footer;
}

function indents(num) {
	function repeat(c, n) {
		var str = "";
		for (var i = 0; i < n; i++) {
			str += c;
		}
		return str;
	}
	var indent = options.indent;
	if ('tab' == indent) {
		return repeat("\t", num);
	} else {
		return repeat(" ", num * parseInt(options.indent));
	}
}

function capitalize(string) {
	return string.replace(/^[a-z]/, function(str) { return str.toUpperCase(); });
}

function underscore(text) {
	return text.replace(/[A-Z]/g, function(str) {
			return '_' + str.toLowerCase();
		});
}

function notOperator() {
	return "!";
}

function logicalAnd(conditions) {
	return conditions.join(" && ");
}

function equals(e1, e2) {
	return new Equals(e1, e2);
}

function Equals(e1, e2) {
	this.e1 = e1;
	this.e2 = e2;
}

Equals.prototype.invert = function() {
	return new NotEquals(this.e1, this.e2);
}

function NotEquals(e1, e2) {
	this.e1 = e1;
	this.e2 = e2;
	this.negative = true;
}

NotEquals.prototype.invert = function() {
	return new Equals(this.e1, this.e2);
}

function RegexpMatch(pattern, expression) {
	this.pattern = pattern;
	this.expression = expression;
}

RegexpMatch.prototype.invert = function() {
	return new RegexpNotMatch(this.pattern, this.expression);
}

RegexpMatch.prototype.assert = function() {
	return assertTrue(this.toString());
}

RegexpMatch.prototype.verify = function() {
	return verifyTrue(this.toString());
}

function RegexpNotMatch(pattern, expression) {
	this.pattern = pattern;
	this.expression = expression;
	this.negative = true;
}

RegexpNotMatch.prototype.invert = function() {
	return new RegexpMatch(this.pattern, this.expression);
}

RegexpNotMatch.prototype.toString = function() {
	return notOperator() + RegexpMatch.prototype.toString.call(this);
}

RegexpNotMatch.prototype.assert = function() {
	return assertFalse(this.invert());
}

RegexpNotMatch.prototype.verify = function() {
	return verifyFalse(this.invert());
}

function seleniumEquals(type, pattern, expression) {
	if (type == 'String[]') {
		return seleniumEquals('String', pattern.replace(/\\,/g, ',') , joinExpression(expression));
	} else if (type == 'String' && pattern.match(/^regexp:/)) {
		return new RegexpMatch(pattern.substring(7), expression);
	} else if (type == 'String' && pattern.match(/^regex:/)) {
		return new RegexpMatch(pattern.substring(6), expression);
	} else if (type == 'String' && (pattern.match(/^glob:/) || pattern.match(/[\*\?]/))) {
		pattern = pattern.replace(/^glob:/, '');
		pattern = pattern.replace(/([\]\[\\\{\}\$\(\).])/g, "\\$1");
		pattern = pattern.replace(/\?/g, "[\\s\\S]");
		pattern = pattern.replace(/\*/g, "[\\s\\S]*");
		return new RegexpMatch("^" + pattern + "$", expression);
	} else {
		pattern = pattern.replace(/^exact:/, '');
		return new Equals(xlateValue(type, pattern), expression);
	}
}

function xlateArgument(value) {
	value = value.replace(/^\s+/, '');
	value = value.replace(/\s+$/, '');
	var r;
	if ((r = /^javascript\{([\d\D]*)\}$/.exec(value))) {
		var js = r[1];
		var parts = [];
		var prefix = "";
		var r2;
		while ((r2 = /storedVars\['(.*?)'\]/.exec(js))) {
			parts.push(string(prefix + js.substring(0, r2.index) + "'"));
			parts.push(variableName(r2[1]));
			js = js.substring(r2.index + r2[0].length);
			prefix = "'";
		}
		parts.push(string(prefix + js));
		return new CallSelenium("getEval", [concatString(parts)]);
	} else if ((r = /\$\{/.exec(value))) {
		var parts = [];
		var regexp = /\$\{(.*?)\}/g;
		var lastIndex = 0;
		var r2;
		while (r2 = regexp.exec(value)) {
			if (this.declaredVars && this.declaredVars[r2[1]]) {
				if (r2.index - lastIndex > 0) {
					parts.push(string(value.substring(lastIndex, r2.index)));
				}
				parts.push(variableName(r2[1]));
				lastIndex = regexp.lastIndex;
			} else if (r2[1] == "nbsp") {
				if (r2.index - lastIndex > 0) {
					parts.push(string(value.substring(lastIndex, r2.index)));
				}
				parts.push(nonBreakingSpace());
				lastIndex = regexp.lastIndex;
			}
		}
		if (lastIndex < value.length) {
			parts.push(string(value.substring(lastIndex, value.length)));
		}
		return concatString(parts);
	} else {
		return string(value);
	}
}

function addDeclaredVar(variable) {
	if (this.declaredVars == null) {
		this.declaredVars = {};
	}
	this.declaredVars[variable] = true;
}

function newVariable(prefix, index) {
	if (index == null) index = 1;
	if (this.declaredVars && this.declaredVars[prefix + index]) {
		return newVariable(prefix, index + 1);
	} else {
		addDeclaredVar(prefix + index);
		return prefix + index;
	}
}

function variableName(value) {
	return value;
}

function concatString(array) {
	return array.join(" + ");
}

function string(value) {
	if (value != null) {
		//value = value.replace(/^\s+/, '');
		//value = value.replace(/\s+$/, '');
		value = value.replace(/\\/g, '\\\\');
		value = value.replace(/\"/g, '\\"');
		value = value.replace(/\r/g, '\\r');
		value = value.replace(/\n/g, '\\n');
		return '"' + value + '"';
	} else {
		return '""';
	}
}

function CallSelenium(message, args) {
	this.message = message;
	if (args) {
		this.args = args;
	} else {
		this.args = [];
	}
}

CallSelenium.prototype.invert = function() {
	var call = new CallSelenium(this.message);
	call.args = this.args;
	call.negative = !this.negative;
	return call;
}

function xlateArrayElement(value) {
	return value.replace(/\\(.)/g, "$1");
}

function parseArray(value) {
	var start = 0;
	var list = [];
	for (var i = 0; i < value.length; i++) {
		if (value.charAt(i) == ',') {
			list.push(xlateArrayElement(value.substring(start, i)));
			start = i + 1;
		} else if (value.charAt(i) == '\\') {
			i++;
		}
	}
	list.push(xlateArrayElement(value.substring(start, value.length)));
	return list;
}

function xlateValue(type, value) {
	if (type == 'String[]') {
		return array(parseArray(value));
	} else {
		return xlateArgument(value);
	}
}

function formatCommand(command) {
	var line = null;
	if (command.type == 'command') {
		var def = command.getDefinition();
		if (def && def.isAccessor) {
			var call = new CallSelenium(def.name);
			for (var i = 0; i < def.params.length; i++) {
				call.args.push(xlateArgument(command.getParameterAt(i)));
			}
			var extraArg = command.getParameterAt(def.params.length)
			if (def.name.match(/^is/)) { // isXXX
				if (command.command.match(/^assert/) ||
					(this.assertOrVerifyFailureOnNext && command.command.match(/^verify/))) {
					line = (def.negative ? assertFalse : assertTrue)(call);
				} else if (command.command.match(/^verify/)) {
					line = (def.negative ? verifyFalse : verifyTrue)(call);
				} else if (command.command.match(/^store/)) {
					addDeclaredVar(extraArg);
					line = statement(assignToVariable('boolean', extraArg, call));
				} else if (command.command.match(/^waitFor/)) {
					line = waitFor(def.negative ? call.invert() : call);
				}
			} else { // getXXX
				if (command.command.match(/^(verify|assert)/)) {
					var eq = seleniumEquals(def.returnType, extraArg, call);
					if (def.negative) eq = eq.invert();
					var method = (!this.assertOrVerifyFailureOnNext && command.command.match(/^verify/)) ? 'verify' : 'assert';
					line = eq[method]();
				} else if (command.command.match(/^store/)) {
					addDeclaredVar(extraArg);
					line = statement(assignToVariable(def.returnType, extraArg, call));
				} else if (command.command.match(/^waitFor/)) {
					var eq = seleniumEquals(def.returnType, extraArg, call);
					if (def.negative) eq = eq.invert();
					line = waitFor(eq);
				}
			}
		} else if (this.pause && 'pause' == command.command) {
			line = pause(command.target);
		} else if (this.echo && 'echo' == command.command) {
			line = echo(command.target);
		} else if ('store' == command.command) {
			addDeclaredVar(command.value);
			line = statement(assignToVariable('String', command.value, xlateArgument(command.target)));
		} else if (command.command.match(/^(assert|verify)Selected$/)) {
			var optionLocator = command.value;
			var flavor = 'Label';
			var value = optionLocator;
			var r = /^(index|label|value|id)=(.*)$/.exec(optionLocator);
			if (r) {
				flavor = r[1].replace(/^[a-z]/, function(str) { return str.toUpperCase() });
				value = r[2];
			}
			var method = (!this.assertOrVerifyFailureOnNext && command.command.match(/^verify/)) ? 'verify' : 'assert';
			var call = new CallSelenium("getSelected" + flavor);
			call.args.push(xlateArgument(command.target));
			var eq = seleniumEquals('String', value, call);
			line = statement(eq[method]());
		} else if (def) {
			if (def.name.match(/^(assert|verify)(Error|Failure)OnNext$/)) {
				this.assertOrVerifyFailureOnNext = true;
				this.assertFailureOnNext = def.name.match(/^assert/);
				this.verifyFailureOnNext = def.name.match(/^verify/);
			} else {
				var call = new CallSelenium(def.name);
				if ("open" == def.name && options.urlSuffix && !command.target.match(/^\w+:\/\//)) {
					// urlSuffix is used to translate core-based test
					call.args.push(xlateArgument(options.urlSuffix + command.target));
				} else {
					for (var i = 0; i < def.params.length; i++) {
						call.args.push(xlateArgument(command.getParameterAt(i)));
					}
				}
				line = statement(call, command);
			}
		} else if (isCustomCommand(command.command)) { //check for known custom command
			this.log.info("custom command: <" + command.command + ">");
			var neg = command.command.match(/^(assert|verify|waitFor)Not/);
			this.log.info("custom command: neg: " + (neg ? "true" : "false"));

			if (command.command.match(/^assert/) || command.command.match(/^verify/)) {
				this.log.info("custom command: assert or verify");
				line = (neg ? assertFalse : assertTrue)(customVerifyCommand(command));
			} else if (command.command.match(/^store/)) {
				this.log.info("custom command: store");
			} else if (command.command.match(/^waitFor/)) {
				this.log.info("custom command: waitFor");
				line = customWaitForCommand(command,neg);
			} else {
				//just a regular "doXXX" command
				this.log.info("custom command: do");
				line = statement(customDoCommand(command));
			}
		} else {
			this.log.info("unknown command: <" + command.command + ">");
			var call = new CallSelenium(command.command);
			if ((command.target != null && command.target.length > 0)
				|| (command.value != null && command.value.length > 0)) {
				call.args.push(string(command.target));
				if (command.value != null && command.value.length > 0) {
					call.args.push(string(command.value));
				}
			}
			line = formatComment(new Comment(statement(call)));
		}
	}
	if (line && this.assertOrVerifyFailureOnNext) {
		line = assertOrVerifyFailure(line, this.assertFailureOnNext);
		this.assertOrVerifyFailureOnNext = false;
		this.assertFailureOnNext = false;
		this.verifyFailureOnNext = false;
	}
	return line;
}

this.remoteControl = true;
this.playable = false;


/*** derived from: java-rc.js ***/
this.name = "flexmonkium";

function useSeparateEqualsForArray() {
	return true;
}

function testMethodName(testName) {
	return "test" + capitalize(testName);
}

function assertTrue(expression) {
	return "assertThat(" + expression.toString() + ", is(equalTo(true)));";
}

function assertFalse(expression) {
	return "assertThat(" + expression.toString() + ", is(equalTo(false)));";
}

var verifyTrue = assertTrue;
var verifyFalse = assertFalse;

function assignToVariable(type, variable, expression) {
	return type + " " + variable + " = " + expression.toString();
}

function ifCondition(expression, callback) {
	return "if (" + expression.toString() + ") {\n" + callback() + "}";
}

function joinExpression(expression) {
	return "FIXME join(" + expression.toString() + ", ',')";
}

function waitFor(expression) {
	return "for (int t = 0;; t++) {\n" +
		"\tif (t >= " + Math.ceil( parseInt(options.timeout) / parseInt(options.poll) ) + ") fail(\"timeout\");\n" +
		"\ttry {\n\t\t"
		+ (expression.setup ? expression.setup() + "\n" : "") +
		"if (" + expression.toString() + ") break;\n"
		+ "\t} catch (Exception e) { }\n" +
		"\tThread.sleep(" + parseInt(options.poll) + ");\n" +
		"}\n";
}

function assertOrVerifyFailure(line, isAssert) {
	return 'try { ' + line + ' fail("expected failure"); } catch (Throwable e) {}';
}

Equals.prototype.toString = function() {
	if (this.e1.toString().match(/^\d+$/)) { // int
		return this.e1.toString() + " == " + this.e2.toString();
	} else { // string
		return this.e1.toString() + ".equals(" + this.e2.toString() + ")";
	}
}

Equals.prototype.assert = function() {
	return "assertThat(" + this.e2.toString() + ", is(equalTo(" + this.e1.toString() + ")));";
}

Equals.prototype.verify = Equals.prototype.assert;

NotEquals.prototype.toString = function() {
	if (this.e1.toString().match(/^\d+$/)) { //int
		return this.e1.toString() + " != " + this.e2.toString();
	} else { // string
		return '!' + this.e1.toString() + ".equals(" + this.e2.toString() + ")";
	}
}

NotEquals.prototype.assert = function() {
	return "assertThat(" + this.e2.toString() + ", not(equalTo(" + this.e1.toString() + ")));";
}

NotEquals.prototype.verify = NotEquals.prototype.assert;

RegexpMatch.prototype.toString = function() {
	if (this.pattern.match(/^\^/) && this.pattern.match(/\$$/)) {
		return this.expression + ".matches(" + string(this.pattern) + ")";
	} else {
		return "Pattern.compile(" + string(this.pattern) + ").matcher(" + this.expression + ").find()";
	}
}

function pause(milliseconds) {
	return "Thread.sleep(" + parseInt(milliseconds) + ");";
}

function echo(message) {
	return "System.out.println(" + xlateArgument(message) + ");";
}

function statement(expression) {
	return expression.toString() + ';';
}

function array(value) {
	var str = 'new String[] {';
	for (var i = 0; i < value.length; i++) {
		str += string(value[i]);
		if (i < value.length - 1) str += ", ";
	}
	str += '}';
	return str;
}

function nonBreakingSpace() {
	return "\"\\u00a0\"";
}

CallSelenium.prototype.toString = function() {
	var result = '';
	if (this.negative) {
		result += '!';
	}
	if (options.receiver) {
		result += options.receiver + '.';
	}
	result += this.message;
	result += '(';
	for (var i = 0; i < this.args.length; i++) {
		result += this.args[i];
		if (i < this.args.length - 1) {
			result += ', ';
		}
	}
	result += ')';
	return result;
}

function formatComment(comment) {
	return comment.comment.replace(/.+/mg, function(str) {
			return "// " + str;
		});
}

function formatSuite(testSuite, filename) {
	var suiteClass = /^(\w+)/.exec(filename)[1];
	suiteClass = suiteClass[0].toUpperCase() + suiteClass.substring(1);

	var suiteClasses = [];
	for (var i = 0; i < testSuite.tests.length; ++i) {
		var testClass = testSuite.tests[i].getTitle();
		suiteClasses.push('\t' + testClass + '.class');
	}

	return 'package ' + options.packageName + ';\n' +
		'\n' +
		'import org.junit.runner.RunWith;\n' +
		'import org.junit.runners.Suite;\n' +
		'\n' +
		'@RunWith(Suite.class)\n' +
		'@Suite.SuiteClasses({\n' +
			suiteClasses.join(',\n') + '\n' +
		'})\n' +
		'public class ' + suiteClass + ' {\n' +
		'}\n';
}

this.options = {
	receiver: "selenium",
	rcHost: "localhost",
	rcPort: "4444",
	environment: "*chrome",
	packageName: "tests",
	superClass: "",
	customCommands: 'doFlexMonkey,isFlexMonkey,getFlexMonkeyCell,getFlexMonkeyValue',
	timeout: '30000',
	poll: '500',
	header:
		'package ${packageName};\n' +
		'\n' +
		'import com.thoughtworks.selenium.*;\n' +
		'import org.junit.*;\n' +
		'import static org.junit.Assert.*;\n' +
		'import static org.hamcrest.CoreMatchers.*;\n' +
		'\n' +
		'public class ${className} extends ${superClass} {\n' +
			'\tprivate Selenium ${receiver};\n' +
			'\tprivate HttpCommandProcessor proc;\n' +
		'\n' +
			'\t@Before\n' +
			'\tpublic void setUp() throws Exception {\n' +
				'\t\tproc = new HttpCommandProcessor("${rcHost}", ${rcPort}, "${environment}", "${baseURL}");\n' +
				'\t\t${receiver} = new DefaultSelenium(proc);\n' +
				'\t\t${receiver}.start();\n' +
			'\t}\n' +
		'\n' +
			'\t@After\n' +
			'\tpublic void tearDown() throws Exception {\n' +
				'\t\tif (${receiver} != null) {\n' +
				'\t\t\t${receiver}.stop();\n' +
				'\t\t\t${receiver} = null;\n' +
				'\t\t}\n' +
			'\t}\n' +
		'\n' +
			'\t@Test\n' +
			'\tpublic void ${methodName}() throws Exception {\n',
	footer: "\t}\n}\n",
	indent: 'tab',
	initialIndents: '2'
};

this.configForm =
'<grid flex="1">\
  <columns>\
	<column/>\
	<column flex="1"/>\
  </columns>\
  <rows>\
	<row>\
	  <label control="options_receiver" value="Instance Variable" /><textbox id="options_receiver" />\
	</row>\
	<row>\
	  <label control="options_rcHost" value="Selenium RC Host" /><textbox id="options_rcHost" />\
	</row>\
	<row>\
	  <label control="options_rcPort" value="Selenium RC Port" /><textbox id="options_rcPort" />\
	</row>\
	<row>\
	  <label control="options_environment" value="Environment" /><textbox id="options_environment" />\
	</row>\
	<row>\
	  <label control="options_packageName" value="Package" /><textbox id="options_packageName" />\
	</row>\
	<row>\
	  <label control="options_superClass" value="Superclass" /><textbox id="options_superClass" />\
	</row>\
	<row>\
	  <label control="options_timeout" value="Timeout" /><textbox id="options_timeout" />\
	</row>\
	<row>\
	  <label control="options_poll" value="Poll Interval" /><textbox id="options_poll" />\
	</row>\
	<row>\
	  <label control="options_header" value="Header" /><textbox id="options_header" multiline="true" rows="6" />\
	</row>\
	<row>\
	  <label control="options_footer" value="Footer" /><textbox id="options_footer" multiline="true" rows="2" />\
	</row>\
  </rows>\
</grid>';


/*** handle custom commands ***/
function customDoCommand(command) {
	if (command.hasOwnProperty('value') && command.value != null) {
		return 'proc.doCommand(' + string(command.command) + ', ' + array([command.target, command.value]) + ')';
	} else {
		return 'proc.doCommand(' + string(command.command) + ', ' + array([command.target]) + ')';
	}
}

function customVerifyCommand(command) {
	return 'proc.getBoolean(' + string('is' + command.command.replace(/^(assert|verify|waitFor)(Not)?/,'')) + ', ' + array([command.target]) + ')';
}

function customWaitForCommand(command,neg) {
	return "for (int t = 0;; t++) {\n" +
		"\tif (t >= " + Math.ceil( parseInt(options.timeout) / parseInt(options.poll) ) + ") fail(\"timeout\");\n" +
		"\ttry {\n\t\t" +
		"if (" + (neg ? '!' : '') + customVerifyCommand(command) + ") break;\n"
		+ "\t} catch (Exception e) { }\n" +
		"\tThread.sleep(" + parseInt(options.poll) + ");\n" +
		"}\n";
}

function isCustomCommand(cmd) {
	var rawCmds = options.customCommands.split(',');
	var cmds = [];
	//convert the raw commands (doFoo, isFoo) into Selenium commands (foo, fooAndWait, assertFoo, etc.)
	for(var i=0; i<rawCmds.length; i++) {
		var raw = rawCmds[i];
		if (raw.match(/^do/)) {
			var c = raw.substr(2,1).toLowerCase() + raw.substr(3);
			cmds.push(c);
		} else if (raw.match(/^is/)) {
			var c = raw.substr(2,1) + raw.substr(3);
			cmds = cmds.concat(['assert' + c, 'verify' + c, 'waitFor' + c, 'assertNot' + c, 'verifyNot' + c, 'waitForNot' + c, 'store' + c]);
		} else if (raw.match(/^get/)) {
			var c = raw.substr(3,1).toLowerCase() + raw.substr(4);
			cmds = cmds.concat(['assert' + c, 'verify' + c, 'waitFor' + c, 'assertNot' + c, 'verifyNot' + c, 'waitForNot' + c, 'store' + c]);
		} else if (raw.match(/^assert/)) {
			var c = raw.substr(6,1).toLowerCase() + raw.substr(7);
			cmds = cmds.concat(['assert' + c, 'verify' + c, 'waitFor' + c]);
		}
	}

	//test if given command matches any know custom command
	for(var i=0; i<cmds.length; i++) {
		if (cmds[i] == cmd) return true;
	}
	for(var i=0; i<rawCmds.length; i++) {
		if (rawCmds[i] == cmd) return true;
	}	
	

	return false;
}