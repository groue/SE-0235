typealias AlamofireResult<Value> = Result<Value, Error>

struct SomeError: Error { }

// Initializing AlamofireResult (don't use the Result identifier at all)
do {
    func makeInt() throws -> Int { return 1 }
    let result1 = AlamofireResult(makeInt)
    let result2 = AlamofireResult { 1 }
    let result3 = AlamofireResult { throw SomeError() }
    let result4: AlamofireResult<Int> = AlamofireResult(makeInt)
    let result6 = AlamofireResult.success(1)
    let result7 = AlamofireResult<Int>.failure(SomeError())
}

// Contravariance: result with typed error -> AlamofireResult
do {
    // A function that wants a AlamofireResult<Int>
    func consumeResult(_ result: AlamofireResult<Int>) { }

    // A Result<Int, SomeError>
    let typedResult = Result<Int, SomeError>.failure(SomeError())

    // compiler error: cannot convert value of type 'Result<Int, SomeError>' to expected argument type 'AlamofireResult<Int>' (aka 'Result<Int, Error>')
    // consumeResult(typedResult)

    // Turn Result<Int, SomeError> into AlamofireResult<Int> - Solution 1
    consumeResult(typedResult.mapError { $0 })

    // Turn Result<Int, SomeError> into AlamofireResult<Int> - Solution 2
    let mappedResult = typedResult.mapError { $0 as Error }
    consumeResult(mappedResult)
}

// Map & flatMap
do {
    // Simple map
    let result1 = AlamofireResult.success(1).map { $0 + 1 }
    assert(result1.value == 2)

    let result2 = AlamofireResult.success(1).map { "\($0)" }
    assert(result2.value == "1")

    // Slight misuse: flatMap without try (think about compactMap)
    let result3 = AlamofireResult.success(1).flatMap { "\($0)" }
    assert(result3.value == "1")

    // Slight misuse: flatMap without value
    let result4 = AlamofireResult.success(1).flatMap { _ in throw SomeError() }
    assert(result4.isSuccess == false)

    func increment(_ int: Int) throws -> Int { return int + 1 }
    let result5 = AlamofireResult.success(1).flatMap(increment)
    assert(result5.value == 2)

    func stringify(_ int: Int) throws -> String { return "\(int)" }
    let result6 = AlamofireResult.success(1).flatMap(stringify)
    assert(result6.value == "1")
}

// flatMap ambiguities
do {
    func incrementResult(_ int: Int) -> AlamofireResult<Int> { return Result.success(int + 1) }
    func stringifyResult(_ int: Int) -> AlamofireResult<String> { return Result.success("\(int)") }

    // compiler error: ambiguous use of 'flatMap'
    // let result1 = AlamofireResult.success(1).flatMap(incrementResult)
    // compiler error: ambiguous use of 'flatMap'
    // let result2 = AlamofireResult.success(1).flatMap(stringifyResult)
}
