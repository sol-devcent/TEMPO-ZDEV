*REPORT zabpxin_macro_sel_scr.

*$*$-Block Name---------------------------------------------------------
*$*$-Simplifies creation of Screen blocks
*$*$--------------------------------------------------------------------
DEFINE begin_of_block.
  selection-screen begin of block &1 with frame title &2.
END-OF-DEFINITION.

DEFINE blankline.
  selection-screen uline.
  selection-screen skip 1.
END-OF-DEFINITION.

DEFINE end_of_block.
  selection-screen end of block &1.
END-OF-DEFINITION.

DEFINE radioleft.
  selection-screen begin of line.
  selection-screen position &1.
  selection-screen comment (&2) &3
  parameter &4 as radiobutton group &5.
  selection-screen end of line.
END-OF-DEFINITION.

DEFINE radioright.
  selection-screen begin of line.
  selection-screen position &1.
  parameter &4 radiobutton group &5.
  selection-screen comment (&2) &3 for field &4.
  selection-screen end of line.
END-OF-DEFINITION.

DEFINE checkleft.
  selection-screen begin of line.
  selection-screen position &1.
  selection-screen comment (&2) &3.
  parameter &4 as checkbox.
  selection-screen end of line.
END-OF-DEFINITION.

DEFINE checkright.
  selection-screen begin of line.
  selection-screen position &1.
  parameter &4 as checkbox.
  selection-screen comment (&2) &3 for field &4.
  selection-screen end of line.
END-OF-DEFINITION.
