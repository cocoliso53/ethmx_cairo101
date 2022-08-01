from web3 import Web3
# Substitute for adecuate values
program_hash = 0x39c4ead4bce418310a6df15cdaa331fc27d07ec813dc4d73c3dc14def32649b
# If multiple outputs just add elements to the list
program_output = [5]

output_hash = Web3.solidityKeccak(['uint256[]'], [program_output])
fact = Web3.solidityKeccak(['uint256', 'bytes32'],[program_hash, output_hash])