# Var2Compform
Script to re-create subentries of senses after the SFM file has been imported into FLEx.

For detailed instructions see: https://sites.google.com/sil.org/importing-sfm-to-flex/workflow/6-detour-subentries-of-senses/b-subentry-promotion-instructions?authuser=0

### Var2Compform.ini
sample:
```
FwdataIn=FwProject-before.fwdata
FwdataOut=FwProject.fwdata
modeltag1=Model Compound
modifytag1=_COMPOUND_
modeltag2=Model Contraction
modifytag2=_CONTRACTION_
numberofmodels=2
```
Do not change the FwdataIn and FwdataOut this is done automatically by the script.
* The model tags should match the data in your custom SPEC field in FLEx.
* The modify tags should match the data in the \spec field in your SFM file.

If you change the number of model/modify pairs make sure they are numbered correctly and
The _numberofmodels_ field at the bottom matches the number of fields.
