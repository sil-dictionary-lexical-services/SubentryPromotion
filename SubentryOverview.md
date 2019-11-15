# Overview of process for importing subentries of senses

## Rationale
FieldWorks (FLEx) can import subentries at the entry level, but there is no provision for importing subentries at the sense level.

When an SFM file has subentries at the sense level, the file can be adjusted to "pretend" these subentries are actually variants, since FLEx import does allow variants of senses.  With appropriate setup and pre- and post-processing, the .fwdata file created by such an import can be adjusted so these entries can be changed from being variants to complex forms (subentries).
## Prepping the SFM file
Before attempting this process, be sure all the other checking and cleanup you would normally do before importing is done.  That includes:
- Verify all entries that need homographs have them and they are unique. Recommended script: Add_HM.pl (verify)
- Split any compound references (e.g., reversals or cross-refs that have more than one target in the field, separated by semicolon).  For instance, the file can have more than one \re field, and each \re field should have only one target in it.  Same for \cf, \sy, \an, and any other lexical relations, as well as \va, \se, \mn. Recommended script: SplitRefs-re.pl (fix)
- Verify that all references point to an entry (or sense) that exists in the database.  (For entries that don't have a valid target, change their marker to something that can be imported into a custom field.)  Recommended script: Check-Refs.pl (verify)
- Verify the structure in Solid
- Check for fields that may need different markers at the Entry vs. Subentry level in the hierarchy.  (May be needed for the "promote subentries" stage.  Candidate fields include \ps and \sn.) (verify)
- Normalize values of \ps, and set up the empty database to be pre-populated with all the values (both name and abbreviation). (This is not strictly needed for the subentry situation; it is just good practice.)  Do the same for any other list items (e.g., source, languages, custom semantic domains).
## Preparing for import
To prepare for importing the SFM file in a way that allows adjusting the subentries of senses in the .fwdata file, the following steps are needed:
### Set up the empty FW database
### Promote the subentries (for a single complex form type)
### Promote the subentries (for more than one complex form type)
### Import the SFM file
## After import
Once the import is completed, make a backup for safe keeping.  Then the following steps are needed:
### Run the hackFWvariants.pl script
## Cleaning up
