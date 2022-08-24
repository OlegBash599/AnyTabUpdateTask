*&---------------------------------------------------------------------*
*& Include          ZC8A_005_DEMO_REP_EVNT
*&---------------------------------------------------------------------*

INITIALIZATION.
  CREATE OBJECT go_app.

START-OF-SELECTION.
  go_app->start_of_sel( ).

end-of-SELECTION.
  go_app->end_of_sel( ).
