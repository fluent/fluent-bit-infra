# Importing resources from cloudflare

go get -u github.com/cloudflare/cf-terraforming/...
cf-terraforming --token TOKEN_ID -z ZONE_ID record  | grep -i resource
```shell
DEBU[0000] Processing record                             Content=166.78.105.113 ID=67c3eccf0a0834b01884701016dffd8a Name=backup.fluentbit.io RecordResourceName=A_backup_fluentbit_io_67c3eccf0a0834b01884701016dffd8a Type=A
DEBU[0000] Processing record                             Content=147.75.192.91 ID=f39b751e3ebbbad7355c5ee13f4319db Name=builder.fluentbit.io RecordResourceName=A_builder_fluentbit_io_f39b751e3ebbbad7355c5ee13f4319db Type=A
DEBU[0000] Processing record                             Content=139.178.64.142 ID=e4ebbc597ba56e701e36b22b716192f1 Name=dev-arm.fluentbit.io RecordResourceName=A_dev-arm_fluentbit_io_e4ebbc597ba56e701e36b22b716192f1 Type=A
DEBU[0000] Processing record                             Content=139.178.85.103 ID=063e25925fd0883192c5e59136fecadd Name=fluentbit.io RecordResourceName=A_fluentbit_io_063e25925fd0883192c5e59136fecadd Type=A
DEBU[0000] Processing record                             Content=139.178.85.103 ID=f7ce9c8999d7f4fa812ff1176543e81e Name=packages.fluentbit.io RecordResourceName=A_packages_fluentbit_io_f7ce9c8999d7f4fa812ff1176543e81e Type=A
DEBU[0000] Processing record                             Content=147.75.53.77 ID=bbea913930c29ee79a82eaa643fc4120 Name=perf-test.fluentbit.io RecordResourceName=A_perf-test_fluentbit_io_bbea913930c29ee79a82eaa643fc4120 Type=A
DEBU[0000] Processing record                             Content=139.178.85.103 ID=6605d6a28d316ca2c1fcf4fe1c55d78c Name=www.fluentbit.io RecordResourceName=A_www_fluentbit_io_6605d6a28d316ca2c1fcf4fe1c55d78c Type=A
DEBU[0000] Processing record                             Content=hosting.gitbook.com ID=e2ca6fd8bc5ac015448c741d0b850e61 Name=docs.fluentbit.io RecordResourceName=CNAME_docs_fluentbit_io_e2ca6fd8bc5ac015448c741d0b850e61 Type=CNAME

terraform import cloudflare_record.root-www bbb9a1aa534bb80b90bfa7ea32eaf536/063e25925fd0883192c5e59136fecadd
terraform import cloudflare_record.www bbb9a1aa534bb80b90bfa7ea32eaf536/6605d6a28d316ca2c1fcf4fe1c55d78c
terraform import cloudflare_record.docs bbb9a1aa534bb80b90bfa7ea32eaf536/e2ca6fd8bc5ac015448c741d0b850e61
```

