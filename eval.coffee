

if module?.exports?
	{parser} = require 'coffee-script/lib/coffee-script/parser'
	{Lexer} = require 'coffee-script/lib/coffee-script/lexer'
	nodes = require 'coffee-script/lib/coffee-script/nodes'
	{last} = require 'coffee-script/lib/coffee-script/helpers'
else
	{parser} = CoffeeScript.require './parser'
	{Lexer} = CoffeeScript.require './lexer'
	nodes = CoffeeScript.require './nodes'
	{last} = CoffeeScript.require './helpers'


lexer = new Lexer

parse = (code) ->
	parser.parse lexer.tokenize code

##################################################
# helpers
##################################################

unescape_string = (s) ->
	# TODO: unescape
	return s

##################################################
# eval
##################################################

eval_property = (base, property) ->
	if property instanceof nodes.Access
		if not property.name.asKey
			throw new Error("Assert Error: property.name.asKey")
		base[property.name.value]
	else
		throw new Error("Not Implemented: #{property.constructor.name}")

eval_value2 = (node, context) ->
	base = null
	value = eval_tree node.base, context
	for property in node.properties
		base = value
		value = eval_property value, property
	return [base, value]

eval_value = (node, context) ->
	eval_value2(node, context)[1]

eval_args = (args, context) ->
	for a in args
		eval_tree a, context

eval_call = (node, context) ->
	if node.isNew
		throw Error("Not Implemented")
	if node.isSuper
		throw Error("Not Implemented")
#	console.log node.variable
	variable = node.variable
	if not variable instanceof nodes.Value
		throw Error("Not Implemented")
	if variable.properties.length > 0 and last(variable.properties) instanceof nodes.Access
		[self, f] = eval_value2 variable, context
	else
		[self, f] = eval_value2 variable, context
	f.apply self, eval_args node.args, context

eval_block = (node, context) ->
	for expr in node.expressions
		result = eval_tree expr, context
	return result

eval_literal = (node, context) ->
	value = node.value
	if value.match /^[$a-zA-Z][$\w]*$/
		context[value]
	else if value.match /^\d+$/
		parseInt value
	else if value.match /^\d+\.\d+$/
		parseFloat value
	else if value.match /^['"].*['"]$/
		unescape_string value.substring 1, value.length - 1
	else if value.match /^\/(.*)\/(\w+)$/
		m = value.match /^\/(.*)\/(\w+)/
		return new RegExp m[1], m[2]
	else
		throw Error("Not Implemented: #{value}")

eval_array = (node, context) ->
	result = []
	for e in node.objects
		result.push eval_tree e, context
	return result

eval_dict = (node, context) ->
	if not node.generated
		throw new Error("Assert Error: node.generated")
	result = {}
	for property in node.properties
		if not property instanceof nodes.Assign
			throw new Error("Assert Error: property instanceof nodes.Assign")
		{variable, value} = property
		k = variable.base.value
		if not k.match /^\w+$/
			if k.match /^['"].*['"]$/
				k = unescape_string k.substring 1, k.length - 1
			else
				throw new Error("Not Implemented: #{k}")
		v = eval_tree value, context
		result[k] = v
	return result

eval_op = (node, context) ->
	if node.operator == '+'
		return eval_tree(node.first, context) + eval_tree(node.second, context)
	if node.operator == '-'
		return eval_tree(node.first, context) - eval_tree(node.second, context)
	if node.operator == '*'
		return eval_tree(node.first, context) * eval_tree(node.second, context)
	if node.operator == '/'
		return eval_tree(node.first, context) / eval_tree(node.second, context)
	if node.operator == '%'
		return eval_tree(node.first, context) % eval_tree(node.second, context)
	throw new Error("Not Implemented: #{node.operator}")

eval_expr = (node, context) ->
	throw Error("Not Implemented: #{node}")

eval_tree = (node, globals) ->
	if node instanceof nodes.Block
		eval_block node, globals
	else if node instanceof nodes.Call
		eval_call node, globals
	else if node instanceof nodes.Value
		eval_value node, globals
	else if node instanceof nodes.Literal
		eval_literal node, globals
	else if node instanceof nodes.Arr
		eval_array node, globals
	else if node instanceof nodes.Obj
		eval_dict node, globals
	else if node instanceof nodes.Op
		eval_op node, globals
	else
#		console.error node
#		console.error node.constructor
		throw Error("Not Implemented: #{node}")

##################################################
# API
##################################################

eval_coffee = (code, globals = {}) ->
	eval_tree parse(code), globals

exports = eval_coffee

if module?.exports?
	module.exports = exports
else
	this.CoffeeScriptEval = exports

