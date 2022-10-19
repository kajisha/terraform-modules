# aws_network_acl module

## コンセプト
resource `aws_network_acl` のルール番号について、「新たに追加したsubnetのcidrに対して同一ルールを同一優先度で付与したい」ケースが存在する。  
このとき、ルール番号を変更するとdestroy and createが走るため、できるだけルール番号を改番したくない。

そこで、以下のようにする:
- `var.acl_rules` において、1ルールごとに `var.rule_number_reserved_block_size` 個のルール番号を予約する。
- ルール番号は、ルール内の `cidr_blocks` 間で連番とする。
- `cidr_blocks` が `var.rule_number_reserved_block_size * n - 1` を超えるときは、追加で `var.rule_number_reserved_block_size * n` 個のルール番号を予約する。

こうすることで、1ルールあたりの `cidr_blocks` のサイズを増減に対しての改番が走る回数を抑制できる。
