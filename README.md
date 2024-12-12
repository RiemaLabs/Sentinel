<div align="left">
  <h1>
    <img src="./resources/sentinel.png" width=50>
  	Sentinel
  </h1>
</div>


Sentinel: Counter-Attack Synthesis for On-Chain Exploit Mitigation

## Dependencies

- Racket (8.0+): https://racket-lang.org/
  - rosette (4.0+): https://github.com/emina/rosette
    - `raco pkg install --auto rosette`
- Foundry/anvil: https://github.com/foundry-rs/foundry

## Example Counter-Attack Synthesis

First start a local `anvil` rpc server by running:

```bash
anvil --fork-url https://eth-mainnet.g.alchemy.com/v2/<YOUR_API_KEY> --order fees --fork-block-number 21380960 --port 8545 --host 127.0.0.1 --allow-origin \"*\" --chain-id 1 --no-mining --timestamp 0 --disable-block-gas-limit --block-base-fee-per-gas 0 --transaction-block-keeper 20
```

Then run the synthesizer:

```bash
racket ./tests/ex0.rkt
```

When you see the following output (`tx0-modified addr` may change):

```
# start mitigation
  # start synthesis
    # holes: (#(struct:hole 0 address ()))
    # prog0 assignment: (1390849295786071768276380950238675083608645509734)
  # end synthesis
  # tx0-modified status: 0x1
  # tx0-modified addr: 0xb06c856c8eabd1d8321b687e188204c1018bc4e5
  # tx1-modified status: 0x1
# end mitigation
# start validation (replay of attacker's transactions)
  # tx0 status: 0x1
  # tx1 status: 0x0
# end validation
# done
```

then the counter-attack is done successfully, as the attacker's replay transactions (`tx0` and `tx1`) are interrputed. In particular, `tx1` is reverted due to the counter-attacks (`tx0-modified` and `tx1-modified`).

## Example Commands

- Quickly start a local anvil node (and disable auto mining):

  ```bash
  anvil --fork-url https://eth-mainnet.g.alchemy.com/v2/<YOUR_API_KEY> --order fees --fork-block-number 14684299 --port 8545 --host 127.0.0.1 allow-origin \"*\" --chain-id 1 --no-mining --timestamp 0 --disable-block-gas-limit --block-base-fee-per-gas 0 --transaction-block-keeper 20
  ```

- Run any tests:

  ```bash
  racket ./tests/test7.rkt
  ```