# Converting Subentries into Variant/Entries
This directory contains a perl script for converting sub-entries into separate entries that have links back to the sense of the main entry.

It also has a wrapper script for handling sub-sub-entries and multiple sub-entry types (complex).

## Sub-subentries
Both the simple and the complex forms allow for sub-sub-entries. A sub-sub-entry is marked by ** \\se*xx*** where ***xx*** represents the corresponding marker for a sub-entry.

In the case of a simple sub-entry, the marker for a sub-entry is **\se**. The marker for a sub-sub-entry would be **\sese**.

In the case of a complex sub-entry, an idiom might be marked as **\li**. An idiom sub-sub-entry would then be marked with **\seli**.

Sub-sub-entrries are handled the same way as sub-entries. First. all the sub-entries are promoted to entries. The sub-entries are then promoted to entries with the sub-entry as the main entry for the sub-sub-entry.

The special handling of sub-sub-entries is not done by the script, but is handled by the way they are specified in the *.ini* files. Sub-entries are ended by other sub-entries, but not by sub-sub-entries. This means that when a sub-entry gets promoted, its sub-sub-entries are included in it.

When all the sub-entries have been promoted, the sub-sub-entries are then just sub-entries within the newly promoted entries. They are promoted last and maintain the original structure.
