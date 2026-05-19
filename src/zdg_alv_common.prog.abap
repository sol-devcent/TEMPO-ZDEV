*----------------------------------------------------------------------*
*   INCLUDE ZIBM_ALV_COMMON                                            *
*----------------------------------------------------------------------*
TYPE-POOLS: slis.

FIELD-SYMBOLS: <fs_table> TYPE table.

*     Internal Tables and Working Areas
DATA: gt_alv_fieldcat     TYPE slis_t_fieldcat_alv,
      wa_alv_fieldcat     TYPE slis_fieldcat_alv,
      gt_alv_event        TYPE slis_t_event,
      wa_alv_event        TYPE slis_alv_event,
      gt_alv_sort         TYPE slis_t_sortinfo_alv,
      wa_alv_sort         TYPE slis_sortinfo_alv,
      gt_alv_filter       TYPE slis_t_filter_alv,
      wa_alv_filter       TYPE slis_filter_alv,
      gt_event_exit       TYPE slis_t_event_exit,
      wa_event_exit       TYPE slis_event_exit,
      gt_alv_exclude      TYPE slis_t_extab,
      wa_alv_exclude      type slis_extab,
      gt_alv_header       type SLIS_T_LISTHEADER,
      wa_alv_header       type SLIS_LISTHEADER,

      o_grid              TYPE REF TO cl_gui_alv_grid, " new

*     Structures
      gs_alv_variant      TYPE disvariant,
      gs_alv_list_scroll  TYPE slis_list_scroll,
      gs_alv_keyinfo      TYPE slis_keyinfo_alv,
      gs_alv_formname     TYPE slis_formname,
      gs_alv_ucomm        TYPE slis_formname,
      gs_alv_print        TYPE slis_print_alv,
      gs_alv_layout       TYPE slis_layout_alv,

*     Global Variables
      gv_alv_screen_start_column TYPE i,
      gv_alv_screen_start_line   TYPE i,
      gv_alv_screen_end_column   TYPE i,
      gv_alv_screen_end_line     TYPE i,
      gv_alv_sort_postn          TYPE i.
