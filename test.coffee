
eval_coffee = require './eval'
_ = require 'underscore'

##################################################
# test utilities
##################################################

eq = (x, y) ->
	_.isEqual x, y

repr = (x) ->
	try
		return JSON.stringify x
	catch error
		return x

check_eval = (expected, code, context) ->
	try
		result = eval_coffee code, context
	catch error
		return ok: false, message: error
	if not eq expected, result
		return ok: false, message: "Expected: #{repr expected}, actual: #{repr result}, by\n#{code}"
	return ok: true

assert_eval = (expected, code, context) ->
	result = check_eval expected, code, context
	if not result.ok
		if result.message.stack
			console.error result.message.stack
		else
			console.error result.message

##################################################
# test environment
##################################################

id = (x) -> x

class Op
	add: (x, y) ->
		x + y

class Int
	constructor: (@value = 0) ->
	inc: (x = 1) ->
		@value += x
	dec: (x = -1) ->
		@value -= x

int = (i = 0) ->
	i

inc = (x) ->
	x + 1

add = (x, y) ->
	x + y

op = new Op()
i = new Int()

##################################################
# test cases
##################################################

assert_eval 1, "1"
assert_eval '1', "'1'"
assert_eval 'i', '"i"'
assert_eval 7, "i", i: 7
assert_eval i, "i", i: i
assert_eval i.value, "i.value", i: i
assert_eval int(), "int()", int: int
assert_eval int(2), "int(2)", int: int
assert_eval new Int().inc(), "i.inc()", i: new Int()
assert_eval op.add(1, 2), "op.add(1, 2)", op: op

assert_eval true, "/x/i.test 'x'"
assert_eval true, "/x/i.test 'X'"
assert_eval false, "/x/i.test 'a'"

assert_eval [1, 2, 3], '[1, 2, 3]'
assert_eval a: 1, b: 2, 'a: 1, b: 2'
assert_eval id(a: 1, b: 2), 'id a: 1, "b": 2', id: id

assert_eval 1 + 1, '1 + 1'
assert_eval 1 - 1, '1 - 1'
assert_eval 1 * 1, '1 * 1'
assert_eval 1 / 1, '1 / 1'
assert_eval 1 % 1, '1 % 1'
assert_eval 1 + 2 * 3 / 4 % 5, '1 + 2 * 3 / 4 % 5'

