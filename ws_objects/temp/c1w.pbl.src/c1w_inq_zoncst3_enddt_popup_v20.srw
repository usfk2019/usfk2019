$PBExportHeader$c1w_inq_zoncst3_enddt_popup_v20.srw
$PBExportComments$[ohj] 홀세일 대역별 요율 등록 적용종료일 일괄처리 popup v20
forward
global type c1w_inq_zoncst3_enddt_popup_v20 from w_base
end type
type st_2 from statictext within c1w_inq_zoncst3_enddt_popup_v20
end type
type st_1 from statictext within c1w_inq_zoncst3_enddt_popup_v20
end type
type p_close from u_p_close within c1w_inq_zoncst3_enddt_popup_v20
end type
type p_ok from u_p_ok within c1w_inq_zoncst3_enddt_popup_v20
end type
type dw_cond from u_d_external within c1w_inq_zoncst3_enddt_popup_v20
end type
type gb_1 from groupbox within c1w_inq_zoncst3_enddt_popup_v20
end type
end forward

global type c1w_inq_zoncst3_enddt_popup_v20 from w_base
integer width = 1851
integer height = 532
string title = "적용종료일 일괄처리"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_close ( )
event ue_ok ( )
st_2 st_2
st_1 st_1
p_close p_close
p_ok p_ok
dw_cond dw_cond
gb_1 gb_1
end type
global c1w_inq_zoncst3_enddt_popup_v20 c1w_inq_zoncst3_enddt_popup_v20

type variables
DataWindowChild idc_itemcod
string is_return
end variables

forward prototypes
public function integer wf_dropdownlist (readonly datawindow adw_obj, long al_row, string as_col)
end prototypes

event ue_close();closewithreturn(this,is_return)
Close(This)
end event

event ue_ok();//표준 요금 조회
String   ls_priceplan, ls_pgm_id, ls_enddt, ls_return
Integer   li_result, li_rc
Date ld_enddt

dw_cond.accepttext()

//ldt_sysdate = fdt_get_dbserver_now() 
ls_enddt = string(dw_cond.object.enddt[1], 'yyyymmdd')
ld_enddt = dw_cond.object.enddt[1]
//필수 항목 Check
If ls_enddt = "" Then
	f_msg_info(200, Title,"적용종료일")
	dw_cond.SetFocus()
	dw_cond.SetColumn("enddt")
   Return
End If

c1u_dbmgr_v20 lu_dbmgr
//저장
lu_dbmgr = Create c1u_dbmgr_v20
lu_dbmgr.is_caller = "c1w_inq_zoncst3_enddt_popup_v20%update"
lu_dbmgr.is_title = Title
//lu_dbmgr.idw_data[1] = dw_detail
lu_dbmgr.is_data[1]  = iu_cust_msg.is_data[3] //svccod
lu_dbmgr.is_data[2]  = iu_cust_msg.is_data[1] //priceplan						//변경전..
lu_dbmgr.is_data[3]  = iu_cust_msg.is_data[4] //zoncod
lu_dbmgr.id_data[1]  = ld_enddt  	 //착신전환부가서비스품목 todt

lu_dbmgr.uf_prc_db()
li_rc = lu_dbmgr.ii_rc

If li_rc = -1 Or li_rc = -2 or li_rc = -3 Then
	is_return = '2'
	Rollback;
	Destroy lu_dbmgr
	f_msg_info(3010,This.Title,"Save")
	Return
else
	is_return = '1'
	commit;	
	f_msg_info(3000,This.Title,"Save")
End If

Destroy lu_dbmgr
//
////복사한다.
//dw_check.RowsCopy(1,dw_check.RowCount(), &
//								Primary!,iu_cust_msg.idw_data[1] ,1, Primary!)
//								
////해당 PricePlan으로 Setting
//ll_row = iu_cust_msg.idw_data[1].RowCount()
//For i = 1 To ll_row
//	iu_cust_msg.idw_data[1].object.svccod[i]    = ls_svccod_old
//	iu_cust_msg.idw_data[1].object.priceplan[i] = ls_priceplan_old
//	iu_cust_msg.idw_data[1].object.pgm_id[i]	  = ls_pgm_id
//	iu_cust_msg.idw_data[1].object.crt_user[i]  = gs_user_id
//	iu_cust_msg.idw_data[1].object.crtdt[i]     = ldt_sysdate
//	iu_cust_msg.idw_data[1].object.updt_user[i] = gs_user_id
//	iu_cust_msg.idw_data[1].object.updtdt[i]    = ldt_sysdate
//Next


end event

public function integer wf_dropdownlist (readonly datawindow adw_obj, long al_row, string as_col);String ls_svccod, ls_Doc_D1, ls_sql

dataWindowChild	dwc_child

adw_obj.GetChild (as_col, dwc_child)
dwc_child.SetTransObject (SQLCA)

adw_obj.Accepttext()

Choose Case lower (as_col)
	Case "priceplan" 
		ls_svccod = fs_snvl(dw_cond.object.svccod[1], '')
		ls_sql  = "		SELECT DISTINCT 'ALL' PRICEPLAN_DESC               " &
		        + "         , 'ALL' PRICEPLAN                             " &
				  + "         , 'ALL' svccod                                " &
				  + "      FROM PRICEPLANMST                                " &
				  + "     WHERE PRICETABLE = (SELECT REF_CONTENT            " & 
				  + "                           FROM SYSCTL1T               " &
				  + "                          WHERE MODULE = 'B0'          " & 
				  + "                            AND REF_NO = 'P100')       " &
				  + " UNION ALL                                             " &
				  + "    SELECT priceplan_desc, priceplan, svccod           " &
				  + "      FROM priceplanmst                                " &
				  + "     WHERE use_yn ='Y'                                 " &
				  + "       and pricetable = (select ref_content            " &
				  + "                           from sysctl1t               " &
				  + "                          where module = 'B0'          " &
				  + "                            and ref_no = 'P100')       " &
				  + "       AND SVCCOD     = '" + ls_svccod +             "'" &
				  + "  ORDER BY priceplan, priceplan_desc                   " 
				  
	Case Else
	
		dwc_child.Retrieve ()

End Choose

If ls_sql <> "" Then dwc_child.SetSQLSelect(ls_sql)

dwc_child.Retrieve ()
//adw_obj.uf_MatchDDDW (as_col)

Return 0
end function

on c1w_inq_zoncst3_enddt_popup_v20.create
int iCurrent
call super::create
this.st_2=create st_2
this.st_1=create st_1
this.p_close=create p_close
this.p_ok=create p_ok
this.dw_cond=create dw_cond
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_2
this.Control[iCurrent+2]=this.st_1
this.Control[iCurrent+3]=this.p_close
this.Control[iCurrent+4]=this.p_ok
this.Control[iCurrent+5]=this.dw_cond
this.Control[iCurrent+6]=this.gb_1
end on

on c1w_inq_zoncst3_enddt_popup_v20.destroy
call super::destroy
destroy(this.st_2)
destroy(this.st_1)
destroy(this.p_close)
destroy(this.p_ok)
destroy(this.dw_cond)
destroy(this.gb_1)
end on

event open;call super::open;/*-------------------------------------------------------
	Name	: c1w_inq_zoncst3_enddt_popup_v20
	Desc.	: 대역별 요율등록 - 적용종료일 일괄처리 popup
	Ver.	: 1.0
	Date	: 2006.01.11
	Programer : oh hye jin
---------------------------------------------------------*/
Long   ll_row
String ls_svccod, ls_filter

f_center_window(c1w_inq_zoncst3_enddt_popup_v20)

dw_cond.object.enddt[1]	 = fdt_get_dbserver_now()

dw_cond.Setfocus()

Return 0 

end event

type st_2 from statictext within c1w_inq_zoncst3_enddt_popup_v20
integer x = 91
integer y = 352
integer width = 1006
integer height = 48
integer textsize = -9
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 128
long backcolor = 29478337
string text = "현재 사용중인 대역만 적용 됩니다."
boolean focusrectangle = false
end type

type st_1 from statictext within c1w_inq_zoncst3_enddt_popup_v20
integer x = 59
integer y = 292
integer width = 1385
integer height = 84
integer textsize = -9
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 128
long backcolor = 29478337
string text = "%적용개시일이 입력하신 일자보다 이전일자이면서"
boolean focusrectangle = false
end type

type p_close from u_p_close within c1w_inq_zoncst3_enddt_popup_v20
integer x = 1527
integer y = 164
boolean originalsize = false
end type

type p_ok from u_p_ok within c1w_inq_zoncst3_enddt_popup_v20
integer x = 1527
integer y = 48
end type

type dw_cond from u_d_external within c1w_inq_zoncst3_enddt_popup_v20
integer x = 82
integer y = 120
integer width = 1001
integer height = 132
integer taborder = 10
string dataobject = "c1dw_cnd_reg_zoncst3_enddt_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

event itemchanged;call super::itemchanged;//String ls_svccod, ls_filter
//Long   ll_row
//
//dw_cond.Accepttext()
//
//ls_svccod = fs_snvl(dw_cond.object.svccod[1], '')
//
////서비스별 가격정책 가져오기 all포함 
//ll_row = dw_cond.GetChild("priceplan", idc_itemcod)
//If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
//
//ls_filter = "svccod IN ('ALL', '" + ls_svccod + "') "
//idc_itemcod.SetFilter(ls_filter)			//Filter정함
//idc_itemcod.Filter()
//idc_itemcod.SetTransObject(SQLCA)
//ll_row =idc_itemcod.Retrieve()
//
//If ll_row < 0 Then 				//디비 오류 
//	f_msg_usr_err(2100, Title, "Retrieve()")
//	Return -2
//Else
//	dw_cond.SetColumn("priceplan")	//찾았을 경우 적용이 빨리 안되서
//End If
//
end event

event clicked;call super::clicked;//wf_dropdownlist(This, This.getrow(), This.GetColumnName())
end event

type gb_1 from groupbox within c1w_inq_zoncst3_enddt_popup_v20
integer x = 27
integer width = 1440
integer height = 432
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
borderstyle borderstyle = stylelowered!
end type

