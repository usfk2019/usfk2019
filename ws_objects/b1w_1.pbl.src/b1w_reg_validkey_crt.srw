$PBExportHeader$b1w_reg_validkey_crt.srw
$PBExportComments$[islim] 인증키생성관리
forward
global type b1w_reg_validkey_crt from w_a_reg_m_m
end type
type dw_file from datawindow within b1w_reg_validkey_crt
end type
end forward

global type b1w_reg_validkey_crt from w_a_reg_m_m
integer width = 3365
dw_file dw_file
end type
global b1w_reg_validkey_crt b1w_reg_validkey_crt

forward prototypes
public subroutine of_resizepanels ()
end prototypes

public subroutine of_resizepanels ();dw_detail.Width = 1600
end subroutine

on b1w_reg_validkey_crt.create
int iCurrent
call super::create
this.dw_file=create dw_file
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_file
end on

on b1w_reg_validkey_crt.destroy
call super::destroy
destroy(this.dw_file)
end on

event open;call super::open;dw_master.Object.idate[1] = fdt_get_dbserver_now()

dw_file.Enabled = False

end event

event resize;//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0

	p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space

	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)

end event

event type integer ue_insert();Constant Int LI_ERROR = -1
Long ll_row

ll_row = dw_detail.InsertRow(dw_detail.rowcount()+1)


dw_detail.Object.num[ll_row]	= ll_row								//인증키
dw_detail.ScrollToRow(ll_row)
dw_detail.SetRow(ll_row)
dw_detail.SetFocus()

dw_master.Object.iqty[1] = ll_row

Return 0

end event

event ue_ok();call super::ue_ok;long ll_cnt

//### 인증키 생성 정보
String ls_validkey_type
String ls_idate
Long	 ll_iqty
String ls_remark

If dw_master.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망
	dw_master.SetFocus()
	Return
End If

ls_validkey_type = Trim(dw_master.Object.validkey_type[1])
ls_idate = Trim(String(dw_master.Object.idate[1],'yyyymmdd'))
ll_iqty = dw_master.Object.iqty[1]
ls_remark = Trim(dw_master.Object.remark[1])


//### 필수데이터 체크

//인증Key Type
IF IsNull(ls_validkey_type) THEN
	f_msg_usr_err(200, Title, "인증Key Type")
	dw_master.setColumn("validkey_type")
	dw_master.setRow(1)
	dw_master.setFocus()
	RETURN
END IF


//생성일자
IF IsNull(ls_idate) or ls_idate = "" THEN
	f_msg_usr_err(200, Title, "생성일자")
	dw_master.setColumn("idate")
	dw_master.setRow(1)
	dw_master.setFocus()
	RETURN
END IF

Long ll_validkeymst_seq			//인증키등록seq.
//인증키등록seq. 추출
	SELECT seq_validkeycrt.nextval
	INTO :ll_validkeymst_seq
	FROM dual;

dw_master.Object.iseqno[1]	= ll_validkeymst_seq								//인증키등록seq	




//### 인증키마스터 정보 입력
Long ll_detailRow //dw_detail의 row수
ll_detailRow = dw_detail.rowCount()


//dw_detail의 row 수 > 생성정보에 입력된 생성수량
IF( ll_detailRow > ll_iqty ) THEN
	FOR ll_cnt=ll_iqty+1 TO ll_detailRow
		dw_detail.deleteRow(ll_iqty+1)	//수량차이 만큼 dw_detail에 Row삭제
	Next
ELSEIF( ll_detailRow < ll_iqty ) THEN
	FOR ll_cnt=ll_detailRow+1 TO ll_iqty
		dw_detail.insertRow(ll_cnt)	//수량차이 만큼 dw_detail에 Row추가
		dw_detail.Object.num[ll_cnt]	= ll_cnt
	Next
END IF

//File DW 활성화
dw_file.Enabled = True
dw_detail.Enabled = True

p_insert.TriggerEvent("ue_enable")
p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

end event

event type integer ue_reset();call super::ue_reset;p_ok.TriggerEvent("ue_enable")

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")

dw_detail.Enabled = False
dw_detail.reset()

dw_master.Enabled = True
dw_master.reset()
dw_master.insertRow(1)
dw_master.Object.idate[1] = fdt_get_dbserver_now()

dw_file.reset()
dw_file.insertRow(1)
dw_file.Enabled = False
RETURN 0

end event

event type integer ue_save();Constant Int LI_ERROR = -1

Long result


If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if


If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3010,This.Title,"Save")
	Return LI_ERROR
//End if
//
//
//If (dw_master.Update() < 0) or (dw_detail.Update() < 0) then
//	//ROLLBACK와 동일한 기능
//	iu_cust_db_app.is_caller = "ROLLBACK"
//	iu_cust_db_app.is_title = This.Title
//
//	iu_cust_db_app.uf_prc_db()
//	
//	If iu_cust_db_app.ii_rc = -1 Then
//		dw_detail.SetFocus()
//		Return LI_ERROR
//	End If
//	
//	f_msg_info(3010,This.Title,"Save")
//	Return LI_ERROR
Else
	
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	
	f_msg_info(3000,This.Title,"Save")
End if

//저장완료
//TriggerEvent("ue_reset")
//p_ok.TriggerEvent("ue_disable")

p_ok.TriggerEvent("ue_enable")

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")

dw_detail.Enabled = False
dw_detail.reset()

dw_master.Enabled = True
dw_master.reset()
dw_master.insertRow(1)
dw_master.Object.idate[1] = fdt_get_dbserver_now()

dw_file.reset()
dw_file.insertRow(1)
dw_file.Enabled = False
//p_insert.TriggerEvent("ue_disable")
//p_delete.TriggerEvent("ue_disable")
//p_save.TriggerEvent("ue_disable")
//
//dw_master.Enabled = False
//dw_file.Enabled = False
//dw_detail.Enabled = False
//
//ii_error_chk = 0
Return 0

end event

event type integer ue_delete();Long ll_row
Long ll_cnt

ll_row = dw_detail.getRow()

IF(ll_row > 0 ) THEN

	dw_detail.DeleteRow(ll_row)
	
	FOR ll_cnt=ll_row to dw_detail.rowCount()
		dw_detail.Object.num[ll_cnt] = dw_detail.Object.num[ll_cnt] -1
	Next
	
	dw_master.Object.iqty[1] = dw_detail.rowCount()

END IF

Return 0

end event

event type integer ue_extra_save();Long		ll_rows, ll_rowcnt
Long		ll_iseqno   		//인증키등록 seq
String	ls_validkey			//validkey
String	ls_validkey_type	//인증Key Type
String	ls_status			//개통상태
String   ls_sale_flag 		//재고구분
String   ls_remark, ls_idate
DATETIME	   ld_idate				//생성일자
String	ls_partner 			//할당대리점
String	ls_partner_prefix //할당대리점Prefix
Long     ll_iqty

Long  ll_rc

b1u_dbmgr8 lu_dbmgr
lu_dbmgr = CREATE b1u_dbmgr8


ll_iseqno   = dw_master.object.iseqno[1]
ld_idate		= dw_master.Object.idate[1]	
ll_iqty     = dw_master.Object.iqty[1]
ls_validkey_type =dw_master.Object.validkey_type[1]
ls_remark	= Trim(dw_master.Object.remark[1])							//비고


//dw_master의 입고수량을 실제 입력된 row수로 정정한다.
dw_master.Object.iqty[1] = ll_rows

	
ll_rows = dw_detail.RowCount()
If ll_rows = 0 Then Return 0


lu_dbmgr.is_caller = "b1w_reg_validkey_crt%save"
lu_dbmgr.is_title  = Title
lu_dbmgr.idw_data[1] = dw_detail
lu_dbmgr.idw_data[2] = dw_master
lu_dbmgr.il_data[1] = ll_iseqno
lu_dbmgr.il_data[2] = ll_iqty 
lu_dbmgr.idt_data[1] = ld_idate
lu_dbmgr.is_data[1] = ls_validkey_type 
lu_dbmgr.is_data[2] = ls_remark


lu_dbmgr.uf_prc_db()
ll_rc = lu_dbmgr.ii_rc

If ll_rc < 0 Then
	dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)		
	Destroy lu_dbmgr
	Return ll_rc
End If

Destroy lu_dbmgr

Return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_validkey_crt
boolean visible = false
end type

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_validkey_crt
integer x = 2985
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_validkey_crt
integer x = 2985
integer y = 176
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_validkey_crt
boolean visible = false
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_validkey_crt
integer x = 23
integer y = 24
integer width = 2912
integer height = 448
string dataobject = "b1dw_cnd_validkey_crt"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_master::clicked;//상속막음
end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_validkey_crt
integer x = 23
integer y = 508
integer width = 1600
integer height = 1120
string dataobject = "b1dw_reg_validkeymst"
end type

event dw_detail::constructor;call super::constructor;This.SetRowFocusIndicator(off!)
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_validkey_crt
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_validkey_crt
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_validkey_crt
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_validkey_crt
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_validkey_crt
integer x = 23
integer y = 472
end type

type dw_file from datawindow within b1w_reg_validkey_crt
integer x = 1659
integer y = 508
integer width = 1522
integer height = 256
integer taborder = 50
boolean bringtotop = true
string title = "none"
string dataobject = "b8dw_file_reg_adin"
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

event buttonclicked;CHOOSE CASE	dwo.Name
	CASE "search"	//파일찾기
		string pathName, fileName

		Int value

		value = GetFileOpenName("Select File", &
				+ pathName, fileName, "TXT", &
				+ "Text Files (*.TXT),*.TXT")

		IF value = 1 THEN
			This.Object.filename[1] = pathName
		END IF
		
	CASE "load"		//파일처리
		String 	ls_fileName
		Int		li_fileId
		
		ls_fileName = Trim(This.Object.filename[1])
		IF isNull(ls_fileName) THEN ls_fileName = ""
		
		IF ls_fileName = "" THEN
			f_msg_info(200, This.Title, "파일명")
			This.SetFocus()
			RETURN 0
		END IF
		
		li_fileId = FileOpen(ls_fileName, LineMode!) //한줄씩 읽어오기
		
		If(IsNull(li_fileId) or li_fileId < 0) THEN
			f_msg_usr_err(200, Title, "파일열기 실패")
			this.setFocus()
			RETURN 0
		End If
		
		String	ls_fileRow			//파일내용이 한줄 저장되는 변수
		Long		ll_fileRows = 0	//파일의 row수가 저장되는 변수
		Long		ll_iqty				//현재 입고예정인 row수
		String	ls_validkey			//새 장비번호
		Long		ll_row				//새로 입력된 row
		Int		li_location			//Text가공시 필요한 위치정보
		
		ll_iqty = dw_detail.rowCount()
		
		//End of File(return -100)을 만날때까지 파일을 한줄씩 읽는다.
		DO UNTIL( FileRead(li_fileId,ls_fileRow) = -100 )
			
			IF(ls_fileRow <> "") THEN
			
				ll_fileRows++
				
				IF( ll_iqty < ll_fileRows) THEN //생성예정 수량보다 파일row수가 많은 경우
					ll_row = dw_detail.InsertRow(dw_detail.rowcount()+1)				
					dw_detail.Object.num[ll_row] = ll_row
					dw_master.Object.iqty[1] = ll_row
				END IF
								
		
				//추출된 시리얼넘버
				ls_fileRow = TRIM(ls_fileRow)
				//ls_fileRow = TRIM(RIGHT(ls_fileRow,li_location+1))
//				ls_fileRow = TRIM(MID(ls_fileRow,li_location+1,Len(ls_fileRow)))
				IF(ls_fileRow <> "") THEN
					dw_detail.Object.validkey[ll_fileRows] = ls_fileRow
				END IF
			END IF	
		LOOP
		
		FileClose(li_fileId) //파일닫기
		
		//생성예정 보다 파일에서 읽은 인증Key 가 작을 경우 경고
		IF(dw_detail.rowcount() > ll_fileRows) THEN
			MessageBox("인증Key 부족","생성수량보다 파일로 입력된 인증Key.수량이 적습니다.")
			ll_fileRows++
		END IF
		
		//마지막 row로 간다.
		dw_detail.ScrollToRow(ll_fileRows)
		dw_detail.SetRow(ll_fileRows)
		dw_detail.SetFocus()
						
END CHOOSE
end event

event constructor;InsertRow(0)
end event

