# Goerli Demo Contract:
# Contract address: 0x022b0f298db2f1776f24cda70f431566d9ef1d0e54a52ee6d930b80ec8c55a62
# Transaction hash: 0x4c5358076492f735956a02dd7d917972d28e2b33db98829f0b1a4928d0ceb20
%lang starknet

# starknet-compile storage.cairo --output storage_compiled.json
# starknet deploy --gateway_url http://localhost:5050 --contract storage_compiled.json
from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.starknet.common.syscalls import storage_read
from starkware.cairo.common.hash import hash2

const SINGLE_KEY = 0x259a7ae4e23df025d5bead0bbd3eb2b756283fc3088b592e179533be7dd1251
const MULTI_KEY = 0x12871215cdec46a1b610066e09151ccd5eed3824ebe4ba02596c69361a2f91
const STRUCT_KEY = 0x1f071b583a1f24f97d31c8451c71ff92a697bc29fdbbee219fd19d325703adf
const MAPPING_KEY = 0x338fd2e7646d570c5c310eaf05ca39446bd5679dff96ec529ca657a3c214bb8

struct Custom:
    member left : felt
    member center : felt
    member right : felt
end

#
# '@storage_var' decorator declares a variable that will be kept as part of the contract storage
#   - can consist of a single felt, or map to custom types(tuple, structs)
#   - '.read' and '.write' utility functions are created automatically for storage variables
#
@storage_var
func single_store() -> (res : felt):
end

@storage_var
func mapping_store(idx : felt) -> (res : felt):
end

@storage_var
func multi_store() -> (res : (left : felt, right : felt)):
end

@storage_var
func struct_store() -> (res : Custom):
end

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    single_store.write(1)
    mapping_store.write(100, 123)
    mapping_store.write(200, 567)
    multi_store.write((left=456, right=789))
    struct_store.write(Custom(left=101112, center=131415, right=161718))

    return ()
end

#
# '@view' functions can be used to read contract storage
#
@view
func get_single_store{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (value : felt):
    let (value) = single_store.read()
    return (value)
end

@view
func get_mapping_store{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(lookup : felt) -> (value : felt):
    let (value) = mapping_store.read(idx=lookup)
    return (value)
end

@view
func get_multi_store{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (value : (left : felt, right : felt)):
    let (value) = multi_store.read()
    return (value)
end

@view
func get_struct_store{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (value : Custom):
    let (value) = struct_store.read()
    return (value)
end

#
# direct storage access for demonstration purposes
#
@view
func get_single_store_literal{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (value : felt):
    let (value) = storage_read(SINGLE_KEY)
    return (value)
end

@view
func get_mapping_store_literal{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(lookup : felt) -> (value : felt):
    let (key) = hash2{hash_ptr=pedersen_ptr}(MAPPING_KEY, lookup)
    let (value) = storage_read(key)
    return (value)
end

@view
func get_multi_store_literal{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (value : (left : felt, right : felt)):
    let (left) = storage_read(MULTI_KEY)
    let (right) = storage_read(MULTI_KEY+1)

    return ((left, right))
end

@view
func get_struct_store_literal{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (value : Custom):
    let (left) = storage_read(STRUCT_KEY)
    let (center) = storage_read(STRUCT_KEY+1)
    let (right) = storage_read(STRUCT_KEY+2)

    return (Custom(left, center, right))
end


#
# '@external' functions can be used to write to contract storage
#
@external
func update_single_store{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(value : felt):
    single_store.write(value)

    return ()
end

@external
func update_multi_store{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(value : (left : felt, right : felt)):
    multi_store.write(value)

    return ()
end

@external
func update_struct_store{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(value : Custom):
    struct_store.write(value)

    return ()
end