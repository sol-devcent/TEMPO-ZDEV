*&---------------------------------------------------------------------*
*&  Include           ZHSMMM_E008TOP
*&---------------------------------------------------------------------*
TYPES : BEGIN OF ty_data,
          prgrp   TYPE rmcp3-prgrp,
          pgktx   TYPE rmcp3-pgktx,
          werks   TYPE rmcp3-werks,
          meins   TYPE rmcp3-meins,
          omima   TYPE rmcp3-omima,
          omipg   TYPE rmcp3-omipg,
          nrmit   TYPE rmcp3-nrmit,
          wemit   TYPE rmcp3-wemit,
          memit   TYPE rmcp3-memit,
          txmit   TYPE rmcp3-txmit,
        END OF ty_data.

DATA : gt_omipg    TYPE STANDARD TABLE OF ty_data,
       gt_omima    TYPE STANDARD TABLE OF ty_data.
