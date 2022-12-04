enum Network {
  mainnet(0x80),
  testnet(0xEF);

  final int prefix;
  const Network(this.prefix);
}