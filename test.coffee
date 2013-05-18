
eval_coffee = require './eval'

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

check_eval = (expected, code, context) ->
	try
		result = eval_coffee code, context
	catch error
		return ok: false, message: error
	if expected != result
		return ok: false, message: "Expected: #{expected}, actual: #{result}, by\n#{code}"
	return ok: true

assert_eval = (expected, code, context) ->
	result = check_eval expected, code, context
	if not result.ok
		console.error result.message

op = new Op()
i = new Int()

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

