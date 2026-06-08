FUNCTION-POOL zhsm_eproc.                   "MESSAGE-ID ..
TYPE-POOLS : p99sg.

TYPES : BEGIN OF ty_lfa1.
        INCLUDE STRUCTURE lfa1.
TYPES :   mfrpn   TYPE mara-mfrpn,
          mfrnr   TYPE mara-mfrnr,
          aplfz   TYPE eine-aplfz,
          kbetr   TYPE konp-kbetr,
          konwa   TYPE konp-konwa,
          kpein   TYPE konp-kpein,
          kmein   TYPE konp-kmein,
          datab   TYPE a018-datab,
        END OF ty_lfa1.

TYPES : BEGIN OF ty_text,
          head    TYPE thead,
          line(132),
        END OF ty_text.

INCLUDE zabp_frm.

DATA : p_dest      LIKE tsp03-padest,
       p_disp      LIKE ssfctrlop-preview.

INCLUDE zabp_smartform.

DATA  : gt_004      TYPE STANDARD TABLE OF zgdmmt0004x,
        gt_004c     TYPE STANDARD TABLE OF zgdmmt004c,
        gt_004p     TYPE STANDARD TABLE OF zgdmmt004p,
        gt_004x     TYPE STANDARD TABLE OF zgdmmt004x,
        gt_004y     TYPE STANDARD TABLE OF zgdmmt004y,
        gt_004z     TYPE STANDARD TABLE OF zgdmmt004z,
        gt_006      TYPE STANDARD TABLE OF zhsmmmdt006,
        gt_007      TYPE STANDARD TABLE OF zhsmmmdt007,
        gs_header   TYPE zgdmmst0051x,
        gt_texts    TYPE STANDARD TABLE OF zgdmmst0056.

DATA : gt_lfa1      TYPE STANDARD TABLE OF lfa1,
       gt_mara      TYPE STANDARD TABLE OF mara,
       gs_quarter   TYPE p99sg_quarter.

DATA : ok_code      TYPE sy-ucomm.
