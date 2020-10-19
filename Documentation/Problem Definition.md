### The Problem

The problem is that FLEx doesn't properly import subentries that occur under a sense. It assumes that a subentry occurs at the end of the record.  So if there is a \sn marker after a subentry, FLEx assumes it is part of that subentry, not part of a sense of the main entry.


The main README in the github repo has an example, labelled Improper Subentry Import Example

### MDF has Two Ways to express an entry and subentry structure

##### Way 1 – a single record with embedded sub-entry:
```
\lx Entry
\ps part of speech of entry
\de definition of entry
... [more fields about entry]
\se Sub-entry 1 of Entry
\ps part of speech of subentry 1
\de definition of subentry 1
... [more fields about Sub-entry 1]
\se Sub-entry 2 of Entry
\ps part of speech of subentry 2
\de definition of subentry
... [more fields about Sub-entry 2]
\dt 20/Jul/2020 [date of last edit of Entry]
```
##### Way 2 – Multiple records each sub-entry points back to the main entry:
```
\lx Entry
\ps part of speech of entry
\de definition of entry
... [more fields about entry]
\dt 20/Jul/2020 [date of last edit of entry]
\lx Sub-entry 1 of Entry[d]
\ps part of speech of subentry 1
\mn Entry [reference to Entry – Entry2 would refer to homograph 2]
\de definition of subentry 1
... [more fields about Sub-entry 1 of Entry]
\dt 21/Jul/2020 [date of last edit]
\lx Sub-entry 2 of Entry
\ps part of speech of subentry 2
\de definition of subentry 2
... [more fields about Sub-entry 2 of Entry]
\dt 21/Jul/2020 [date of last edit]
```
#### FLEx 8.3 has problems importing both ways

With Way 1, when the structure is simple, FLEx import can get the Complex Form Type right. When the structure is complicated, it messes up the structure.


With Way 2, FLEx imports them as variants, not subentries, but does import a complicated structure correctly. If you "drop the right breadcrumbs", the Var2Compform.pl script can correct the links.


The se2lx directory has scripts and control files to convert Way 1 to Way 2, with proper breadcrumbs (\spec fields) to get the structure right later.
