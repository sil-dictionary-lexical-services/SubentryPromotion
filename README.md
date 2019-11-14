# Subentry Promotion
This repo contains scripts to process SFM lexical records to promote sub-entries to full entry records. The promoted entry has a marker pointing back to the entry it was under.

FLEx imports subentries only under entries.  In order to import a subentry under a sense, it needs to be recast as a variant (rather than as complex forms) in the SFM file, and then imported, and then changed from Variant to Complex Form in the .fwdata file after the import. This package contains several scripts needed for that process.  One of the scripts promotes embedded subentries to standalone entries (so they can retain all the fields that Complex Forms can have). Another script looks for these entries in the FLEx .fwdata file and changes them from Variant to Complex Form.  These scripts also include a mechanism to customize the complex form type.

This repo was migrated from Wes Peacock's Nkonya dictionary Script directory in June 2019.
