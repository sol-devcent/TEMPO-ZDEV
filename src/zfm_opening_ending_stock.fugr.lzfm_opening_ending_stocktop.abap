FUNCTION-POOL zfm_opening_ending_stock.     "MESSAGE-ID ..

DATA  BEGIN OF gt_mard OCCURS 1.
DATA:   matnr LIKE mard-matnr,
        werks LIKE mard-werks,
        lgort LIKE mard-lgort,
        labst LIKE mard-labst,
        insme LIKE mard-insme,
        speme LIKE mard-speme.
DATA  END   OF gt_mard.

DATA  BEGIN OF gt_s031 OCCURS 1.
DATA:   spmon LIKE s031-spmon,
        matnr LIKE s031-matnr,
        werks LIKE s031-werks,
        lgort LIKE s031-lgort,
        mzubb LIKE s031-mzubb,
        magbb LIKE s031-magbb.
DATA  END   OF gt_s031.
DATA: gt_s031a LIKE gt_s031 OCCURS 0 WITH HEADER LINE.
