# aws_subnet_3layers module

## 概要
典型的な3layer構成のsubnetを簡単に生成するmodule。

"web", "app", "database" の各layer名は、hashicorp learn を参考にした。
https://learn.hashicorp.com/tutorials/terraform/pattern-module-creation?in=terraform/modules


## defaultのaclルール
- 同一layer同士の通信は可能
- web layerからdatabase layerへのEgress通信は不可能
- database layerからdatabase layer以外へのEgress通信は不可能
- web layerからapp layerへのEgress通信は可能
- app layerからweb layerへのEgress通信は可能
- app layerからdatabase layerへのEgressは可能
