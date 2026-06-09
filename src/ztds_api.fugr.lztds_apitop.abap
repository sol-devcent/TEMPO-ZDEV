FUNCTION-POOL ztds_api.                     "MESSAGE-ID ..
TABLES: ztdsitdt001, zmlogika_lgtyp, vbak, ZMOBSDDT001.

TYPES : BEGIN OF ty_matlp,
            sales_office           TYPE string,
            material_code           TYPE string,
          END OF ty_matlp.

DATA: gt_matlp          TYPE TABLE OF ty_matlp,
      gv_str TYPE string,
      gv_vkbur TYPE vstel.
DATA: gt_zmlogika_lgtyp TYPE TABLE OF zmlogika_lgtyp.
DATA: gs_zmlogika_lgtyp TYPE zmlogika_lgtyp.
DATA : gv_message(255).
DATA : gv_status(1).
DATA: gv_contract LIKE vbkd-bstkd_m.
