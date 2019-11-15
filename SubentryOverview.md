# Overview of process for importing subentries of senses

## Rationale
FieldWorks (FLEx) can import subentries at the entry level, but there is no provision for importing subentries at the sense level.

When an SFM file has subentries at the sense level, the file can be adjusted to "pretend" these subentries are actually variants, since FLEx import does allow variants of senses.  With appropriate setup and pre- and post-processing, the .fwdata file created by such an import can be adjusted so these entries can be changed from being variants to complex forms (subentries).
## Prepping the SFM file
### Normal import prep
Before attempting this process, be sure all the other checking and cleanup you would normally do before importing is done.  That includes:
- Make a list of all the fields.  For each, make notes about what Writing System they use, what level of the hierachy they belong to, and whether they require a custom field.
- Collect all the values of the \ps field. Determine (with the owner of the database) if they need to be normalized.  Be sure you know the full name and abbreviation for each value. Do the same for any other list items (e.g., source, languages, custom semantic domains).
- Verify the structure in Solid.
- Create an empty FW database for this language, setting up any necessary writing systems, custom fields, and part of speech values (with both name and abbreviation, possibly in more than one analysis language).  Make backups of the empty database at each stage, putting comments to indicate the stage (e.g., "Empty", "Empty-AddedPOS", "Empty-AddedCustFields").  Importing usually requires multiple attempts, and it is easier to just restore a backup that is all set up, than to redo all of these setup steps repeatedly.
- For more details about best practices for preparing an SFM file for import, see (link to Best Practices doc)  
### Import prep critical for the "promote subentries" process
The following steps are part of a normal import process, and are crucial for the "subentries of senses" procedure:
- Verify all entries that need homographs have them and they are unique. Recommended script: Add_HM.pl (verify)
- Split any compound references (e.g., reversals or cross-refs that have more than one target in the field, separated by semicolon).  For instance, the file can have more than one \re field, and each \re field should have only one target in it.  Same for \cf, \sy, \an, and any other lexical relations, as well as \va, \se, \mn. Recommended script: SplitRefs-re.pl (fix)
- Verify that all references point to an entry (or sense) that exists in the database.  (For entries that don't have a valid target, change their marker to something that can be imported into a custom field.)  Recommended script: Check-Refs.pl (verify)
- Check for fields that may need different markers at the Entry vs. Subentry level in the hierarchy.  (May be needed for the "promote subentries" stage.  Candidate fields include \ps and \sn.) (verify)
## Preparing for this customized import
To prepare for importing the SFM file in a way that allows adjusting the subentries of senses in the .fwdata file, the following steps are needed:
### Set up the empty FW database for the specialized import
Using the empty FW database created above, do the following:
- Create a model entry for the parent of a subentry. (add more details)
- Create a model entry for the subentry of a sense. (add more details)
- Make a backup of this empty database, since it is likely to take several iterations to get the import right.
### Promote the subentries
#### Assumptions around the promotion step
Once the SFM file is well-formed and cleaned up, the subentries of senses need to be promoted main entries. There are several reasons for this:
- First, we are assuming that the subentries in the SFM file are embedded in the entries.  (The alternative would be for the senses to have a \se field in them that references the subentry, and then the subentry exists as its own entry, with an \mn pointing back to the parent entry and sense.  That scenario can be handled, but this document doesn't describe how to do it.  We have rarely seen things set up this way in SFM files.)
- Embedded variant (variants that occur inside an entry) are very limited in terms of what fields they can include.
- The most effective way to represent these subentries is as a separate entry, with all the contents of the subentry, and an \mn field pointing back to the parent entry (including its sense number).
- When a separate entry has an \mn field in it, that entry could be either a variant or a complex form of the parent entry.  The way FLEx determines which it is, is by looking at the parent entry.  If the parent entry has an \se field referring to it then it is a complex form.  If the parent entry has a \va field referring to it, or no reference to it, then it is a variant.
- For this process, we want FLEx to consider them to be variants.
#### Determining what markers signal a subentry has ended
- Using Solid or some other method, determine what markers occur inside a subentry, and which occur at the sense and entry level of the parent entry.
- As the "promote subentries" script is stepping through the SFM file, it needs to know when it is inside a subentry, and when it has hit a marker that signals that it has moved past the end of the subentry, and has now popped back up to the next higher level (either another marker in the parent sense, or a marker that signals the beginning of the next sense, or an entry-level marker, or the end of the record.
- If you can determine what markers fit that criteria, make a note of them.  If there are markers that sometimes indicate the subentry has ended, but other times is still in the subentry, then the SFM file will need to be adjusted so that marker has one shape inside subentries, and a different shape outside subentries.  For instance, if \sn is such a marker, you might use \sn at the entry level and \snSE inside subentries.  This may best be done inside Solid, or it may need to be done manually.
- If the SFM file has subentries at the entry level, those need to be marked with a different marker than the subentries of senses.
- If there are subentries of more than one complex form type, then each different type needs to have a different subentry marker.  For instance, in Philippine dictionaries, some of the subentry markers include \li for idiom, \lc for compound, \ld for derivations.
#### Setting up to promote the subentries for one complex form type
Edit the .ini file to specify the parameters needed:
- Make a copy of the file se2lx.ini and rename it with a code for this project (e.g., se2lx-MMM.ini, where MMM is the ISO-639 code for this language).  Edit this custom file for this project, adjusting the following values:
- SubentryMkr: The marker that indicates the subentries that need to be promoted.  Everything with this marker will be turned into a main entry, with an \mn field pointing back to its parent entry.
- SenseMkr: The marker used to indicate a sense (at the entry level; there may be a different sense marker inside the subentries).  In MDF, this would be \sn.  In PLB dictionaries, it would be \ms.
- SpecialTag: This is the special text that will be used by the hackFWvariants.pl script to determine that this is an item to be adjusted, and what complex form type it should be changed to use.
- EndMkrs: These are the markers that indicate that a subentry has just ended (this marker is at the next higher level than the subentry).
- DateMkr: What marker is used for the date field?  In MDF dictionaries, this is \dt and it is an entry-level field that indicates the subentry has ended.  (It is not necessary to have a date marker.) (verify)
#### Setting up to promote more than one complex form type
If there is more than one complex form type to be promoted, you can have more than one section in the .ini file.
The sample file shows sections for markers lc, ls, ld.  Either adjust these sections for your data, or delete any section you don't need.
#### Running the "promote subentry" script
The script uses the .ini file to determine all the custom values for this project, so you shouldn't need to adjust se2lx.pl at all.
The command for running the script is:  
    perl ./se2lx.pl -inifile se2lx-MMM.ini -section se2lx_lc infile.sfm > outfile.sfm  
If you have more than one complex form type, you will need to run the script once for each type, specifying a different "section" each time:  
    perl ./se2lx.pl -inifile se2lx-MMM.ini -section se2lx_ls infile.sfm > outfile.sfm  
    perl ./se2lx.pl -inifile se2lx-MMM.ini -section se2lx_ld infile.sfm > outfile.sfm  
 Inspect the result to verify that it looks as you expect.  That is:
 - Everything that was a subentry before should be in a separate entry, with \lx for the headword instead of \se (or whatever marker it had as a subentry).
 - It should have an \mn field referring to the \lx of the parent entry, including homograph and sense number.
 - The promoted subentries should come sequentially after the parent entry in the SFM file.
 #### Adjust the homograph numbers
 Since all subentries are considered entries in FLEx, they all are candidates for homograph numbers.  Now that we have promoted all the subentries, they need homograph numbers assigned to them.  The current "add homograph" scripts don't take subentries into account, so we need to add them now.
 Run the script add_hm.pl (verify) to add homograph numbers to the database, now that it has a lot more top-level entries, some of which might be the same as existing entries (that didn't need homograph numbers before).  (Or, if you previously determined that none of the subentries were homographs of parent entries, then this step is not needed.)
### Import the SFM file
Import the resulting SFM file as usual.  In the mapping step, keep these factors in mind:
- Map \mn to "Primary Entry Reference" (at the Entry level).
- For ??, set the Variant Type to ??.  (Maybe this isn't needed?)
- Anything else?
## After import
Once the import is completed, make a backup for safe keeping.  Then the following steps are needed:
### Verify the import worked as expected
- Look for some of the entries that came from promoted subentries.  Verify that they have the special tag where expected.
### Run the hackFWvariants.pl script
- Set up the script ??
- The command for running the script is:
### Verify the hack worked as expected
- Look for the relevant entries
- Are they subentries of senses?
## Cleaning up
If the script worked as expected, you can do some cleanup steps:
- Delete the two model entries.
- Delete the "special tag" on the entries that were promoted.
