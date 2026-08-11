*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_E00X_TOP
*&---------------------------------------------------------------------*
INCLUDE <icon>.

DATA : gs_005       TYPE ztspppdt005.

DATA : ok_code      TYPE sy-ucomm,
       gv_werks     TYPE werks_d,
       gv_nrp(30),
       gv_title(30),
       gv_password(6),
       gv_newpass(6),
       gv_repeat(6),
       gv_subrc    TYPE sy-subrc,
       gv_new,
       gv_info(4),
       gv_encoded   TYPE dbcon_pwd.
