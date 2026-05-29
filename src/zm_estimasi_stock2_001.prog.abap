*----------------------------------------------------------------------*
*   INCLUDE ZGHMMALV001                                                *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   INCLUDE ZIBM_ALV_COMMON                                            *
*----------------------------------------------------------------------*
INCLUDE <icon>.

TYPE-POOLS: slis,abap,truxs.

FIELD-SYMBOLS: <fs_table> TYPE table.

DATA: t_alv_fieldcat      TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      t_alv_event         TYPE slis_t_event WITH HEADER LINE,
      t_events            TYPE slis_t_event,
      t_alv_isort         TYPE slis_t_sortinfo_alv WITH HEADER LINE,
      t_alv_filter        TYPE slis_t_filter_alv WITH HEADER LINE,
      t_event_exit        TYPE slis_t_event_exit WITH HEADER LINE,
      d_exit_caused_by_user TYPE slis_exit_by_user,
      d_alv_isort         TYPE slis_sortinfo_alv,
      d_alv_variant       TYPE disvariant,
      d_alv_list_scroll   TYPE  slis_list_scroll,
      d_alv_sort_postn    TYPE i,
      d_alv_keyinfo       TYPE slis_keyinfo_alv,
      d_alv_fieldcat      TYPE slis_fieldcat_alv,
      d_alv_formname      TYPE slis_formname,
      d_alv_ucomm         TYPE slis_formname,
      d_alv_print         TYPE slis_print_alv,
      d_alv_repid         LIKE sy-repid,
      d_alv_tabix         LIKE sy-tabix,
      d_alv_subrc         LIKE sy-subrc,
      d_alv_screen_start_column TYPE i,
      d_alv_screen_start_line TYPE i,
      d_alv_screen_end_column TYPE i,
      d_alv_screen_end_line TYPE i,
      d_alv_layout TYPE slis_layout_alv.

DATA: d_layout           TYPE slis_layout_alv,
      d_repid            LIKE sy-repid,
      d_print            TYPE slis_print_alv.

DATA:
  d_hdr_rpt_lines VALUE 'X',
  d_hdr_selection(50),
  d_hdr_rpos TYPE i,
  d_hdr_lines TYPE i,
  d_hdr_types,
  d_hdr_intsf,   "Flag for intensified
  d_hdr_low(30),
  d_hdr_high(30),
  d_hdr_atext(80),
  d_hdr_lngth TYPE i,
  d_hdr_title(999),           " Report title with padding
  d_hdr_text1(999),           " User text 1
  d_hdr_text2(999),           " User text 2
  d_hdr_text3(999).           " User text 3

DATA: d_hdr_begrtime TYPE i,
      d_hdr_endrtime TYPE i,
      d_hdr_rtime(15) VALUE 'HH:MM:SS,mm'.
