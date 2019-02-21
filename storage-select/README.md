## storage-select

depending on a given, configuration-time argument, select the concrete device
implementation of KV_RW. Examples in the mirage tool itself are mostly about the "target" key (i.e. select your implementation based on which platform you compile for). Here, instead the selection should be done based on a configuration-time argument - and not all solutions work for all targets (how to express failure at this step?)
