$PBExportHeader$c1w_inq_wholesale_confirm_v20.srw
$PBExportComments$[ohj] 홀세일 매출마감 v20
forward
global type c1w_inq_wholesale_confirm_v20 from w_a_inq_m
end type
type cb_1 from commandbutton within c1w_inq_wholesale_confirm_v20
end type
type st_1 from statictext within c1w_inq_wholesale_confirm_v20
end type
end forward

global type c1w_inq_wholesale_confirm_v20 from w_a_inq_m
integer width = 3026
integer height = 1844
cb_1 cb_1
st_1 st_1
end type
global c1w_inq_wholesale_confirm_v20 c1w_inq_wholesale_confirm_v20

type variables
boolean ib_sort_use
string is_method[], is_type[]
end variables

on c1w_inq_wholesale_confirm_v20.create
int iCurrent
call super::create
this.cb_1=create cb_1
this.st_1=create st_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_1
this.Control[iCurrent+2]=this.st_1
end on

on c1w_inq_wholesale_confirm_v20.destroy
call super::destroy
destroy(this.cb_1)
destroy(this.st_1)
end on

event ue_ok();call super::ue_ok;Long ll_row
String ls_where
String ls_customernm,ls_customerid


//조회시 상단에 입력한 내용으로 조회
ls_customerid = Trim(dw_cond.Object.customerid[1])
ls_customernm = Trim(dw_cond.Object.customernm[1])

If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_customernm) Then ls_customernm = ""

ls_where = ""

If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " A.customerid = '" + ls_customerid + "' "	
End If

If ls_customernm <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " b.customernm like '%" + ls_customernm + "%' "	
End If

dw_detail.is_where = ls_where

ll_row = dw_detail.Retrieve(is_type[1], is_method[1], is_method[2])

If ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
ElseIf ll_row < 0  Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
End If


dw_detail.SelectRow(0, FALSE )
dw_detail.Setrow(1)
dw_detail.SelectRow( 1 , TRUE )








end event

event open;call super::open;/************************************
   홀세일 매출마감(건별)
	2005.11.28 OHJ
************************************/

string ls_temp, ls_ref_desc

//마감주기방식 d;m  daily; monthly
ls_temp = ""
ls_temp = fs_get_control("C1", "C230", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_method[])

//회선사업자정산유형(건당;합산)   0 ;1 
ls_temp = ""
ls_temp = fs_get_control("C1", "C120", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_type[])


end event

type dw_cond from w_a_inq_m`dw_cond within c1w_inq_wholesale_confirm_v20
integer y = 72
integer width = 2094
integer height = 136
string dataobject = "c1dw_cnd_inq_wholesale_confirm_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init;call super::ue_init;
This.is_help_win[1] = "b1w_hlp_customerm"
This.idwo_help_col[1] = dw_cond.object.customerid
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;//Id 값 받기
Choose Case dwo.name
	Case "customerid"
		If This.iu_cust_help.ib_data[1] Then
			 This.Object.customerid[1] = This.iu_cust_help.is_data[1]
 			 //This.Object.customernm[1] = This.iu_cust_help.is_data[2]
		End If
		
End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;String ls_customerid

Choose Case dwo.name
		
	case 'customerid' 
		
		 select nvl(customernm,'')
		   into :ls_customerid
			from customerm
		  where customerid = :data;

		if SQLCA.SQLCODE >= 0 then
			 dw_cond.object.customernm[1] = ls_customerid
		end if					 
end Choose
end event

type p_ok from w_a_inq_m`p_ok within c1w_inq_wholesale_confirm_v20
integer x = 2336
integer y = 40
end type

type p_close from w_a_inq_m`p_close within c1w_inq_wholesale_confirm_v20
integer x = 2638
integer y = 40
end type

type gb_cond from w_a_inq_m`gb_cond within c1w_inq_wholesale_confirm_v20
integer width = 2176
integer height = 244
end type

type dw_detail from w_a_inq_m`dw_detail within c1w_inq_wholesale_confirm_v20
integer y = 260
integer width = 2921
integer height = 1440
string dataobject = "c1dw_inq_wholesale_confirm_v20"
boolean ib_sort_use = false
end type

event dw_detail::ue_init;call super::ue_init;dwObject ldwo_sort

ldwo_SORT = Object.customerid_t
uf_init( ldwo_sort, "D", RGB(0,0,128) )
end event

event dw_detail::constructor;call super::constructor;ib_sort_use = true
end event

event dw_detail::clicked;call super::clicked;If row = 0 then Return
If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If

end event

type cb_1 from commandbutton within c1w_inq_wholesale_confirm_v20
integer x = 2336
integer y = 144
integer width = 585
integer height = 96
integer taborder = 30
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
end type

type st_1 from statictext within c1w_inq_wholesale_confirm_v20
integer x = 2350
integer y = 164
integer width = 558
integer height = 48
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 8388608
long backcolor = 79741120
string text = "매출마감"
alignment alignment = center!
boolean focusrectangle = false
end type

event clicked;Long    ll_row, i, ll_ok = 0, ll_return
double  lb_count
String  ls_errmsg, ls_customerid, ls_closefrdt_nt, ls_closetodt_nt


ll_row = dw_detail.Rowcount()
If ll_row < 1 Then Return

SetPointer ( HourGlass! )

For i = 1 To ll_row
	If dw_detail.object.process_gubun[i] = 'Y' Then
		ls_customerid   = dw_detail.object.customerid[i]
		ls_closefrdt_nt = string(dw_detail.object.closefrdt_nt[i], 'yyyymmdd')
		ls_closetodt_nt = string(dw_detail.object.closetodt_nt[i], 'yyyymmdd')	
		
		//처리부분...
		SQLCA.WholeSale_CrtItemsale(ls_closefrdt_nt, ls_closetodt_nt, ls_customerid, ll_return, ls_errmsg, lb_count)
		If SQLCA.SQLCode < 0 Then		//For Programer
			MessageBox(dw_detail.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
			Return
		ElseIf ll_return < 0 Then	//For User
			MessageBox(dw_detail.Title, ls_errmsg)
			Return
		End If		
		If ll_return <> 0 Then	//실패
		   f_msg_info(9000, dw_detail.Title, "사업자id :" +ls_customerid+'~r~n'+"홀세일 매출마감 실패!!")
			Return			
		Else				//성공
			ll_ok ++			
		End If
	End If
	
	If i < ll_row Then
		dw_detail.SelectRow( i   , FALSE)
		dw_detail.SelectRow( i+1 , TRUE )		
	End If
Next

SetPointer ( Arrow! )
If ll_ok > 0 Then
	f_msg_info(3000, Title, string(ll_ok) +"건 홀세일 매출마감 처리완료!!")
Else
	f_msg_info(4000, Title, "마감처리할 사업자가 선택 되지 않았습니다!!")
End If
end event

