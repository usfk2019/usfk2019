$PBExportHeader$b1w_inq_inv_detail_pop_cv.srw
$PBExportComments$[khpark]  고객정보등록 (청구정보) popup
forward
global type b1w_inq_inv_detail_pop_cv from b1w_inq_inv_detail_cv
end type
end forward

global type b1w_inq_inv_detail_pop_cv from b1w_inq_inv_detail_cv
end type
global b1w_inq_inv_detail_pop_cv b1w_inq_inv_detail_pop_cv

event open;call super::open;f_center_window(This)

//수정 불가능
dw_cond.object.value[1] = "customerid"
dw_cond.object.name[1] = iu_cust_msg.is_data[1]

//Item Changed Event 발생
Trigger Event ue_ok()
end event

on b1w_inq_inv_detail_pop_cv.create
int iCurrent
call super::create
end on

on b1w_inq_inv_detail_pop_cv.destroy
call super::destroy
end on

type dw_cond from b1w_inq_inv_detail_cv`dw_cond within b1w_inq_inv_detail_pop_cv
end type

type p_ok from b1w_inq_inv_detail_cv`p_ok within b1w_inq_inv_detail_pop_cv
end type

type p_close from b1w_inq_inv_detail_cv`p_close within b1w_inq_inv_detail_pop_cv
end type

type gb_cond from b1w_inq_inv_detail_cv`gb_cond within b1w_inq_inv_detail_pop_cv
end type

type dw_master from b1w_inq_inv_detail_cv`dw_master within b1w_inq_inv_detail_pop_cv
end type

type tab_1 from b1w_inq_inv_detail_cv`tab_1 within b1w_inq_inv_detail_pop_cv
end type

type st_horizontal from b1w_inq_inv_detail_cv`st_horizontal within b1w_inq_inv_detail_pop_cv
end type

type dw_cond2 from b1w_inq_inv_detail_cv`dw_cond2 within b1w_inq_inv_detail_pop_cv
end type

type p_find from b1w_inq_inv_detail_cv`p_find within b1w_inq_inv_detail_pop_cv
end type

