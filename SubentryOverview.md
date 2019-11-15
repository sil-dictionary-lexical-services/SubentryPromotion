# Overview of process for importing subentries of senses

## Rationale
FieldWorks (FLEx) can import subentries at the entry level, but there is no provision for importing subentries at the sense level.

When an SFM file has subentries at the sense level, the file can be adjusted to "pretend" these subentries are actually variants, since FLEx import does allow variants of senses.  With appropriate setup and pre- and post-processing, the .fwdata file created by such an import can be adjusted so these entries can be changed from being variants to complex forms (subentries).
## Prepping the SFM file
Before attempting this process, be sure all the other checking and cleanup you would normally do before importing is done.  That includes:
- Make a list of all the fields.  For each, make notes about what Writing System they use, what level of the hierachy they belong to, and whether they require a custom field.
- Collect all the values of the \ps field. Determine (with the owner of the database) if they need to be normalized.  Be sure you know the full name and abbreviation for each value. Do the same for any other list items (e.g., source, languages, custom semantic domains).
- Verify the structure in Solid.
- Create an empty FW database for this language, setting up any necessary writing systems, custom fields, and part of speech values (with both name and abbreviation, possibly in more than one analysis language).
- For more details about best practices for preparing an SFM file for import, see (link to Best Practices doc)
The following steps are part of a normal import process, and are crucial for the "subentries of senses" procedure:
- Verify all entries that need homographs have them and they are unique. Recommended script: Add_HM.pl (verify)
- Split any compound references (e.g., reversals or cross-refs that have more than one target in the field, separated by semicolon).  For instance, the file can have more than one \re field, and each \re field should have only one target in it.  Same for \cf, \sy, \an, and any other lexical relations, as well as \va, \se, \mn. Recommended script: SplitRefs-re.pl (fix)
- Verify that all references point to an entry (or sense) that exists in the database.  (For entries that don't have a valid target, change their marker to something that can be imported into a custom field.)  Recommended script: Check-Refs.pl (verify)
- Check for fields that may need different markers at the Entry vs. Subentry level in the hierarchy.  (May be needed for the "promote subentries" stage.  Candidate fields include \ps and \sn.) (verify)
## Preparing for import
To prepare for importing the SFM file in a way that allows adjusting the subentries of senses in the .fwdata file, the following steps are needed:
### Set up the empty FW database for the specialized import
Using the empty FW database created above, do the following:
- Create a model entry for the parent of a subentry.
- Create a model entry for the subentry of a sense
### Promote the subentries
Once the SFM file is well-formed and cleaned up, the subentries of senses need to be promoted main entries. There are several reasons for this:
- First, we are assuming that the subentries in the SFM file are embedded in the entries.  (The alternative would be for the senses to have a \se field in them that references the subentry, and then the subentry exists as its own entry, with an \mn pointing back to the parent entry and sense.  That scenario can be handled, but this document doesn't describe how to do it.  We have rarely seen things set up this way in SFM files.)
- Embedded variant (variants that occur inside an entry) are very limited in terms of what fields they can include.
- The most effective way to represent these subentries is as a separate entry, with all the contents of the subentry, and an \mn field pointing back to the parent entry (including its sense number).
- When a separate entry has an \mn field in it, that entry could be either a variant or a complex form of the parent entry.  The way FLEx determines which it is, is by looking at the parent entry.  If the parent entry has an \se field referring to it then it is a complex form.  If the parent entry has a \va field referring to it, or no reference to it, then it is a variant.
- For this process, we want FLEx to consider them to be variants.
### Promote the subentries (for more than one complex form type)
### Import the SFM file
## After import
Once the import is completed, make a backup for safe keeping.  Then the following steps are needed:
### Run the hackFWvariants.pl script
## Cleaning up
