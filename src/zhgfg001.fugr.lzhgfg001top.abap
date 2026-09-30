FUNCTION-POOL zhgfg001.                     "MESSAGE-ID ..

INCLUDE zabp_bdc.

TYPES : BEGIN OF ty_putaway,
          warehouse_number     TYPE c LENGTH 3,
          material_number      TYPE c LENGTH 18,
          material_description TYPE c LENGTH 40,
          le_quantity          TYPE c LENGTH 20,
          status               TYPE c LENGTH 1,
          message              TYPE c LENGTH 220,
          nav_to               TYPE STANDARD TABLE OF zhgwmst002 WITH DEFAULT KEY,
        END OF ty_putaway.

TYPES : BEGIN OF ty_confirm,
          warehouse_number     TYPE c LENGTH 3,
          material_number      TYPE c LENGTH 18,
          material_description TYPE c LENGTH 40,
          le_quantity          TYPE c LENGTH 20,
          status               TYPE c LENGTH 1,
          message              TYPE c LENGTH 220,
          nav_conf             TYPE STANDARD TABLE OF zhgwmst002 WITH DEFAULT KEY,
        END OF ty_confirm.

TYPES : BEGIN OF ty_conf,
          warehouse_number         TYPE c LENGTH 3,
          inspection_lot           TYPE c LENGTH 12,
          pallet_number            TYPE c LENGTH 10,
          le_quantity              TYPE c LENGTH 20,
          plant                    TYPE c LENGTH 4,
          material_number          TYPE c LENGTH 18,
          material_description     TYPE c LENGTH 40,
          batch                    TYPE c LENGTH 10,
          quantity                 TYPE c LENGTH 20,
          uom                      TYPE c LENGTH 3,
          destination_storage_type TYPE c LENGTH 3,
          destination_storage_bin  TYPE c LENGTH 10,
          username                 TYPE c LENGTH 12,
          putaway_date             TYPE c LENGTH 20,
          status                   TYPE c LENGTH 1,
          message                  TYPE c LENGTH 220,
        END OF ty_conf.

TYPES : BEGIN OF ty_pidadhoc,
          plant            TYPE c LENGTH 4,
          storage_location TYPE c LENGTH 4,
          username         TYPE c LENGTH 12,
          pid_number       TYPE c LENGTH 10,
          code_stcat       TYPE c LENGTH 1,
          printer_name     TYPE c LENGTH 30,
          type             TYPE c LENGTH 1,
          message          TYPE c LENGTH 220,
          nav_adhoc        TYPE STANDARD TABLE OF zhgwmst014 WITH DEFAULT KEY,
        END OF ty_pidadhoc.

TYPES : BEGIN OF ty_pidyearly,
          plant            TYPE c LENGTH 4,
          pid_number       TYPE c LENGTH 10,
          pid_year         TYPE c LENGTH 4,
          storage_location TYPE c LENGTH 4,
          username         TYPE c LENGTH 12,
          code_stcat       TYPE c LENGTH 1,
          printer          TYPE c LENGTH 30,
          type             TYPE c LENGTH 1,
          message          TYPE c LENGTH 220,
          nav_pidyr        TYPE STANDARD TABLE OF zhgwmst016 WITH DEFAULT KEY,
        END OF ty_pidyearly.

TYPES : BEGIN OF ty_replenish,
          username         TYPE c LENGTH 12,
          warehouse_number TYPE c LENGTH 3,
          to_number        TYPE c LENGTH 10,
          status           TYPE c LENGTH 1,
          message          TYPE c LENGTH 220,
          nav_replenishsys TYPE STANDARD TABLE OF zhgwmst020 WITH DEFAULT KEY,
        END OF ty_replenish.

TYPES : BEGIN OF ty_postrepl,
          username         TYPE c LENGTH 12,
          warehouse_number TYPE c LENGTH 3,
          to_number        TYPE c LENGTH 10,
          process_status   TYPE c LENGTH 10,
          status           TYPE c LENGTH 1,
          message          TYPE c LENGTH 220,
          nav_postreplsys  TYPE STANDARD TABLE OF zhgwmst021 WITH DEFAULT KEY,
        END OF ty_postrepl.

DATA : g_tabgrid TYPE REF TO cl_gui_alv_grid,
       gt_bmerge TYPE swww_t_merge_table,
       gt_fmerge TYPE swww_t_merge_table,
       gt_body   TYPE swww_t_html_table,
       gt_foot   TYPE swww_t_html_table,
       gt_html   TYPE STANDARD TABLE OF w3html.

DATA : gv_lznum   TYPE ltak-lznum.

* INCLUDE LZHGFG001D...                      " Local class definition
