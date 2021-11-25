#### Run a Simple Subentry Promotion Example

1. Create a working directory and navigate to it in WSL.

2. in WSL, run this command to download the setup script:
   `wget https://github.com/sil-dictionary-lexical-services/SubentryPromotion/raw/master/SampleFiles/setup-sepromo-simple.sh`

3. Run the setup script in WSL:
   `./setup-sepromo-simple.sh`
   The *setup-sepromo-simple.sh* script will download the files you need to run a simple version of the Subentry Promotion process.

4. Run FLEx and restore the *BearBullMole* project in the *BearBullMole-Initial-Empty.fwbackup* that was downloaded to your working directory. It contains a project with no records.

5. In FLEx, use the Import SFM feature to import the SFM file *ModelEntries-MDFroot.db*. The file is in your working directory, with the corresponding *.map* file. This initializes the project with a dummy main entry and a set of model subentries under that entry.

6. Run the subentry promotion script in WSL:
   `./runse2lx-simple.sh`
This script reads *BearBullMole-simple.db* and writes to *BearBullMole-simple-promo.db*. It turns the subentries into lexical entries that use \mn markers to refer back to their main entries. It also marks those entries with special markers. FLEx will interpret these entries as variants, but the special markers indicate that these are actually complex forms.

   When it is finished, the script will tell you how many promoted entries there are.

7. In FLEx, use the Import SFM feature to import the *BearBullMole-simple-promo.db*. Here are some things to note:
   * Use the *.map* file that has already been created.
   * The final Import Log for this example has some Parts of Speech and Usages that aren't in the initial FLEx project. For an real-life import, you would correct typos in the SFM database or make changes to the initial empty FLEx project.
   * The final Import Log also notes some missing Lexical Relations and Cross References. In real-life, you would be correct these in the SFM database, and re-run the import.

8. In FLEx, use  *File|Project Management|Back up this Project...* to back up the project. The dialog box has an item that specifies where the *.fwbackup* file will be stored. Take note of that location so you can copy it later.

9. Exit FLEx.

10. Copy the *.fwbackup* file you made in FLEx into the working directory that you have open in WSL. Make sure it's the only *.fwbackup* file in that directory that doesn't have "Initial" in its name.

11. In WSL, run the Variant to Complex Form script:
    `./runVar2Compform.sh`
    This script checks for a number of different types of Complex Forms. In this simple example, the only  Complex Form is the *"Unspecified Complex Form"*. As it modifies the entries in the project, it displays the entry headword and a unique code that FLEx uses for that record. When the entries have all been corrected, it puts the project back into the *.fwbackup* file.

12. In FLEx use the "Restore a Project" function of the Project Management to load the corrected project from the *.fwbackup* file in your working directory. If you restore the project to a different name, you can compare the project before and after.

13. The FLEx database has a field named *"SubEntry Type Flag"*. The special markers mentioned above are stored in this field. If the final import is correct, you can delete that field from the database using the *"Tools|Configure|Custom Fields"*. This menu item is available in the *Lexical Edit* and *Browse* modes.

14. You can also delete the entry *MainEntryForModels* and the model subentries, i.e., *Model Compound*, etc.

This completes the simple Subentry Promotion example.
