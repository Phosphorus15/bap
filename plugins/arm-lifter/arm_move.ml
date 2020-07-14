open Bap_core_theory
open Base
open KB.Syntax
open Bap.Std

module Env  = Arm_env.Env
module Defs = Arm_defs
module Mov(Core : Theory.Core) = struct
  open Core
  module DSL = Arm_dsl.Make(Core)
  module Flags = Arm_flags.Flags(Core)
  module Shift = Arm_shift.Shift(Core)
  module Cond = Arm_cond.Cond(Core)
  open Flags
  open Cond

  (* wflag is valid only when it's (`Reg `CPSR) *)
  let movi dest src cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest
        ]
      ]
    ]

  (* this has exactly the same code as with `movi`, except the src variant is different *)
  let movr dest src cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest
        ]
      ]
    ]

  let movsr dest src sreg simm cond wflag =
    let (shift_operand, carry) = Shift.shift_r src simm sreg in
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := shift_operand;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest;
          Env.cf := carry
        ]
      ]
    ]

  let movsi dest src simm cond wflag =
    let (shift_operand, carry) = Shift.shift_i src simm in
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := shift_operand;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest;
          Env.cf := carry
        ]
      ]
    ]

  (** this is expected with PC change *)
  let movpclr cond wflag =
    (DSL.[
        if_ (resolve_cond cond) [
          Env.pc := var Env.lr;
          when_ (is_cpsr wflag) [
            set_nzf Env.pc;
          ]
        ]
      ], jmp (var Env.pc))

  let mvni dest src cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := not !$src;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest
        ]
      ]
    ]

  let mvnr dest src cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := not !$src;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest
        ]
      ]
    ]

  let mvnsr dest src sreg simm cond wflag =
    let (shift_operand, carry) = Shift.shift_r src simm sreg in
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := not shift_operand;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest;
          Env.cf := carry
        ]
      ]
    ]

  let mvnsi dest src simm cond wflag =
    let (shift_operand, carry) = Shift.shift_i src simm in
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := not shift_operand;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest;
          Env.cf := carry
        ]
      ]
    ]

  let andri dest src1 src2 cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 land !$src2;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest
        ]
      ]
    ]

  let andrr dest src1 src2 cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 land !$src2;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest
        ]
      ]
    ]

  let andrsr dest src1 src2 sreg simm cond wflag =
    let (shift_operand, carry) = Shift.shift_r src2 simm sreg in
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 land shift_operand;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest;
          Env.cf := carry
        ]
      ]
    ]

  let andrsi dest src1 src2 simm cond wflag =
    let (shift_operand, carry) = Shift.shift_i src2 simm in
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 land shift_operand;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest;
          Env.cf := carry
        ]
      ]
    ]

  let bicri dest src1 src2 cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 land lnot !$src2;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest
        ]
      ]
    ]

  let bicrr dest src1 src2 cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 land lnot !$src2;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest
        ]
      ]
    ]

  let bicrsr dest src1 src2 sreg simm cond wflag =
    let (shift_operand, carry) = Shift.shift_r src2 simm sreg in
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 land lnot shift_operand;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest;
          Env.cf := carry
        ]
      ]
    ]

  let bicrsi dest src1 src2 simm cond wflag =
    let (shift_operand, carry) = Shift.shift_i src2 simm in
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 land lnot shift_operand;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest;
          Env.cf := carry
        ]
      ]
    ]

  let eorri dest src1 src2 cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 lxor !$src2;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest
        ]
      ]
    ]

  let eorrr dest src1 src2 cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 lxor !$src2;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest
        ]
      ]
    ]

  let eorrsr dest src1 src2 sreg simm cond wflag =
    let (shift_operand, carry) = Shift.shift_r src2 simm sreg in
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 lxor shift_operand;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest;
          Env.cf := carry
        ]
      ]
    ]

  let eorrsi dest src1 src2 simm cond wflag =
    let (shift_operand, carry) = Shift.shift_i src2 simm in
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 lxor shift_operand;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest;
          Env.cf := carry
        ]
      ]
    ]

  let orrri dest src1 src2 cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 lor !$src2;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest
        ]
      ]
    ]

  let orrrr dest src1 src2 cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 lor !$src2;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest
        ]
      ]
    ]

  let orrrsr dest src1 src2 sreg simm cond wflag =
    let (shift_operand, carry) = Shift.shift_r src2 simm sreg in
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 lor shift_operand;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest;
          Env.cf := carry
        ]
      ]
    ]

  let orrrsi dest src1 src2 simm cond wflag =
    let (shift_operand, carry) = Shift.shift_i src2 simm in
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 lor shift_operand;
        when_ (is_cpsr wflag) [
          set_nzf !$$dest;
          Env.cf := carry
        ]
      ]
    ]

  let teqri src1 src2 cond =
    DSL.[
      if_ (resolve_cond cond) [
        Env.tmp := !$src1 lxor !$src2;
        set_nzf Env.tmp
      ]
    ]

  let teqrr src1 src2 cond =
    DSL.[
      if_ (resolve_cond cond) [
        Env.tmp := !$src1 lxor !$src2;
        set_nzf Env.tmp
      ]
    ]

  let teqrsr src1 src2 sreg simm cond =
    let (shift_operand, carry) = Shift.shift_r src2 simm sreg in
    DSL.[
      if_ (resolve_cond cond) [
        Env.tmp := !$src1 lxor shift_operand;
        set_nzf Env.tmp;
        Env.cf := carry
      ]
    ]

  let teqrsi src1 src2 simm cond =
    let (shift_operand, carry) = Shift.shift_i src2 simm in
    DSL.[
      if_ (resolve_cond cond) [
        Env.tmp := !$src1 lxor shift_operand;
        set_nzf Env.tmp;
        Env.cf := carry
      ]
    ]

  let tstri src1 src2 cond =
    DSL.[
      if_ (resolve_cond cond) [
        Env.tmp := !$src1 land !$src2;
        set_nzf Env.tmp
      ]
    ]

  let tstrr src1 src2 cond =
    DSL.[
      if_ (resolve_cond cond) [
        Env.tmp := !$src1 land !$src2;
        set_nzf Env.tmp
      ]
    ]

  let tstrsr src1 src2 sreg simm cond =
    let (shift_operand, carry) = Shift.shift_r src2 simm sreg in
    DSL.[
      if_ (resolve_cond cond) [
        Env.tmp := !$src1 land shift_operand;
        set_nzf Env.tmp;
        Env.cf := carry
      ]
    ]

  let tstrsi src1 src2 simm cond =
    let (shift_operand, carry) = Shift.shift_i src2 simm in
    DSL.[
      if_ (resolve_cond cond) [
        Env.tmp := !$src1 land shift_operand;
        set_nzf Env.tmp;
        Env.cf := carry
      ]
    ]

  let addri dest src1 src2 cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 + !$src2;
        when_ (is_cpsr wflag) [
          set_add !$src1 !$src2 !$$dest
        ]
      ]
    ]

  let addrr dest src1 src2 cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 + !$src2;
        when_ (is_cpsr wflag) [
          set_add !$src1 !$src2 !$$dest
        ]
      ]
    ]

  let addrsr dest src1 src2 sreg simm cond wflag =
    let (shift_operand, _) = Shift.shift_r src2 simm sreg in
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 + shift_operand;
        when_ (is_cpsr wflag) [
          set_add !$src1 shift_operand !$$dest
        ]
      ]
    ]

  let addrsi dest src1 src2 simm cond wflag =
    let (shift_operand, _) = Shift.shift_i src2 simm in
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 + shift_operand;
        when_ (is_cpsr wflag) [
          set_add !$src1 shift_operand !$$dest
        ]
      ]
    ]

  let subri dest src1 src2 cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 - !$src2;
        when_ (is_cpsr wflag) [
          set_sub !$src1 !$src2 !$$dest
        ]
      ]
    ]

  let subrr dest src1 src2 cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 - !$src2;
        when_ (is_cpsr wflag) [
          set_sub !$src1 !$src2 !$$dest
        ]
      ]
    ]

  let subrsr dest src1 src2 sreg simm cond wflag =
    let (shift_operand, _) = Shift.shift_r src2 simm sreg in
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 - shift_operand;
        when_ (is_cpsr wflag) [
          set_sub !$src1 shift_operand !$$dest
        ]
      ]
    ]

  let subrsi dest src1 src2 simm cond wflag =
    let (shift_operand, _) = Shift.shift_i src2 simm in
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src1 - shift_operand;
        when_ (is_cpsr wflag) [
          set_sub !$src1 shift_operand !$$dest
        ]
      ]
    ]

  let adcri dest src1 src2 cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        (let cf = bool_as_bitv (var Env.cf) in
         !$$dest := !$src1 + !$src2 + cf);
        when_ (is_cpsr wflag) [
          set_adc !$src1 !$src2 !$$dest
        ]
      ]
    ]

  let adcrr dest src1 src2 cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        (let cf = bool_as_bitv (var Env.cf) in
         !$$dest := !$src1 + !$src2 + cf);
        when_ (is_cpsr wflag) [
          set_adc !$src1 !$src2 !$$dest
        ]
      ]
    ]

  let adcrsr dest src1 src2 sreg simm cond wflag =
    let (shift_operand, _) = Shift.shift_r src2 simm sreg in
    DSL.[
      if_ (resolve_cond cond) [
        (let cf = bool_as_bitv (var Env.cf) in
         !$$dest := !$src1 + shift_operand + cf);
        when_ (is_cpsr wflag) [
          set_adc !$src1 shift_operand !$$dest
        ]
      ]
    ]

  let adcrsi dest src1 src2 simm cond wflag =
    let (shift_operand, _) = Shift.shift_i src2 simm in
    DSL.[
      if_ (resolve_cond cond) [
        (let cf = bool_as_bitv (var Env.cf) in
         !$$dest := !$src1 + shift_operand + cf);
        when_ (is_cpsr wflag) [
          set_adc !$src1 shift_operand !$$dest
        ]
      ]
    ]

  let sbcri dest src1 src2 cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        (let cf = bool_as_bitv (var Env.cf) in
         !$$dest := !$src1 - !$src2 - not cf);
        when_ (is_cpsr wflag) [
          set_sbc !$src1 !$src2 !$$dest
        ]
      ]
    ]

  let sbcrr dest src1 src2 cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        (let cf = bool_as_bitv (var Env.cf) in
         !$$dest := !$src1 - !$src2 - not cf);
        when_ (is_cpsr wflag) [
          set_sbc !$src1 !$src2 !$$dest
        ]
      ]
    ]

  let sbcrsr dest src1 src2 sreg simm cond wflag =
    let (shift_operand, _) = Shift.shift_r src2 simm sreg in
    DSL.[
      if_ (resolve_cond cond) [
        (let cf = bool_as_bitv (var Env.cf) in
         !$$dest := !$src1 - shift_operand - not cf);
        when_ (is_cpsr wflag) [
          set_sbc !$src1 shift_operand !$$dest
        ]
      ]
    ]

  let sbcrsi dest src1 src2 simm cond wflag =
    let (shift_operand, _) = Shift.shift_i src2 simm in
    DSL.[
      if_ (resolve_cond cond) [
        (let cf = bool_as_bitv (var Env.cf) in
         !$$dest := !$src1 - shift_operand - not cf);
        when_ (is_cpsr wflag) [
          set_sbc !$src1 shift_operand !$$dest
        ]
      ]
    ]

  let rsbri dest src1 src2 cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src2 - !$src1;
        when_ (is_cpsr wflag) [
          set_sub !$src2 !$src1 !$$dest
        ]
      ]
    ]

  let rsbrr dest src1 src2 cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src2 - !$src1;
        when_ (is_cpsr wflag) [
          set_sub !$src2 !$src1 !$$dest
        ]
      ]
    ]

  let rsbrsr dest src1 src2 sreg simm cond wflag =
    let (shift_operand, _) = Shift.shift_r src2 simm sreg in
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := shift_operand - !$src1;
        when_ (is_cpsr wflag) [
          set_sub shift_operand !$src1 !$$dest
        ]
      ]
    ]

  let rsbrsi dest src1 src2 simm cond wflag =
    let (shift_operand, _) = Shift.shift_i src2 simm in
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := shift_operand - !$src1;
        when_ (is_cpsr wflag) [
          set_sub shift_operand !$src1 !$$dest
        ]
      ]
    ]

  let rscri dest src1 src2 cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        (let cf = bool_as_bitv (var Env.cf) in
         !$$dest := !$src2 - !$src1 - not cf);
        when_ (is_cpsr wflag) [
          set_sbc !$src2 !$src1 !$$dest
        ]
      ]
    ]

  let rscrr dest src1 src2 cond wflag =
    DSL.[
      if_ (resolve_cond cond) [
        (let cf = bool_as_bitv (var Env.cf) in
         !$$dest := !$src2 - !$src1 - not cf);
        when_ (is_cpsr wflag) [
          set_sbc !$src2 !$src1 !$$dest
        ]
      ]
    ]

  let rscrsr dest src1 src2 sreg simm cond wflag =
    let (shift_operand, _) = Shift.shift_r src2 simm sreg in
    DSL.[
      if_ (resolve_cond cond) [
        (let cf = bool_as_bitv (var Env.cf) in
         !$$dest := shift_operand - !$src1 - not cf);
        when_ (is_cpsr wflag) [
          set_sbc shift_operand !$src1 !$$dest
        ]
      ]
    ]

  let rscrsi dest src1 src2 simm cond wflag =
    let (shift_operand, _) = Shift.shift_i src2 simm in
    DSL.[
      if_ (resolve_cond cond) [
        (let cf = bool_as_bitv (var Env.cf) in
         !$$dest := shift_operand - !$src1 - not cf);
        when_ (is_cpsr wflag) [
          set_sbc shift_operand !$src1 !$$dest
        ]
      ]
    ]

  let cmpri src1 src2 cond =
    DSL.[
      if_ (resolve_cond cond) [
        Env.tmp := !$src1 - !$src2;
        set_sub !$src1 !$src2 Env.tmp
      ]
    ]

  let cmprr src1 src2 cond =
    DSL.[
      if_ (resolve_cond cond) [
        Env.tmp := !$src1 - !$src2;
        set_sub !$src1 !$src2 Env.tmp
      ]
    ]

  let cmprsr src1 src2 sreg simm cond =
    let (shift_operand, _) = Shift.shift_r src2 simm sreg in
    DSL.[
      if_ (resolve_cond cond) [
        Env.tmp := !$src1 - shift_operand;
        set_sub !$src1 shift_operand Env.tmp
      ]
    ]

  let cmprsi src1 src2 simm cond =
    let (shift_operand, _) = Shift.shift_i src2 simm in
    DSL.[
      if_ (resolve_cond cond) [
        Env.tmp := !$src1 - shift_operand;
        set_sub !$src1 shift_operand Env.tmp
      ]
    ]

  let cmnri src1 src2 cond =
    DSL.[
      if_ (resolve_cond cond) [
        Env.tmp := !$src1 + !$src2;
        set_add !$src1 !$src2 Env.tmp
      ]
    ]

  let cmnzrr src1 src2 cond =
    DSL.[
      if_ (resolve_cond cond) [
        Env.tmp := !$src1 + !$src2;
        set_add !$src1 !$src2 Env.tmp
      ]
    ]

  let cmnzrsr src1 src2 sreg simm cond =
    let (shift_operand, _) = Shift.shift_r src2 simm sreg in
    DSL.[
      if_ (resolve_cond cond) [
        Env.tmp := !$src1 + shift_operand;
        set_add !$src1 shift_operand Env.tmp
      ]
    ]

  let cmnzrsi src1 src2 simm cond =
    let (shift_operand, _) = Shift.shift_i src2 simm in
    DSL.[
      if_ (resolve_cond cond) [
        Env.tmp := !$src1 + shift_operand;
        set_add !$src1 shift_operand Env.tmp
      ]
    ]

  (** wflag is strictly unused, this seems to be a llvm-mc custom *)
  let movi16 dest src cond _wflag =
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$src
      ]
    ]

  let movti16 dest src cond _wflag =
    DSL.[
      if_ (resolve_cond cond) [
        !$$dest := !$dest lor !$src << imm 16
      ]
    ]

end