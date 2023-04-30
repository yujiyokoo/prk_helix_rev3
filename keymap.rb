require 'mouse'
class Keyboard
  attr_accessor :mouse, :keycodes, :modifier
end

kbd = Keyboard.new

kbd.split = true

# Initialize GPIO assign for Sparkfun Pro Micro RP2040
kbd.init_pins(
  [ 4, 5, 6, 7, 8 ],             # row0, row1,... respectively
  [ 29, 28, 27, 26, 22, 20, 23 ] # col0, col1,... respectively
)

# default layer should be added at first
kbd.add_layer :default, %i[
  KC_GRAVE  KC_1     KC_2     KC_3      KC_4    KC_5   KC_NO    KC_NO    KC_6   KC_7     KC_8     KC_9     KC_0   KC_DELETE
  KC_TAB    KC_QUOTE KC_COMM  KC_DOT    KC_P    KC_Y   KC_NO    KC_NO    KC_F   KC_G     KC_C     KC_R     KC_L   KC_BSPACE
  KC_LCTL   KC_A     KC_O     KC_E      KC_U    KC_I   KC_NO    KC_NO    KC_D   KC_H     KC_T     KC_N     KC_S   KC_MINUS
  KC_LSFT   KC_SCLN  KC_Q     KC_J      KC_K    KC_X   KC_NO    KC_NO    KC_B   KC_M     KC_W     KC_V     KC_Z   KC_RSFT
  RGB_SPD   KC_ESC   KC_LALT  KC_LGUI  KC_BTN1  LOWER  KC_SPACE KC_ENTER RAISE  KC_BTN2  KC_LEFT  KC_DOWN  KC_UP  KC_RIGHT
]
kbd.add_layer :raise, %i[
  KC_F1     KC_F2   KC_F3   KC_F4       KC_F5    KC_F6    KC_NO    KC_NO    KC_F7   KC_F8     KC_F9     KC_F10      KC_F11    KC_BTN3
  KC_GRAVE  KC_EXLM KC_AT   KC_HASH     KC_DLR   KC_PERC  KC_NO    KC_NO    KC_CIRC KC_AMPR   KC_ASTER  KC_LPRN     KC_SLASH  KC_EQUAL
  KC_LCTL   KC_LABK KC_LCBR KC_LBRACKET KC_LPRN  KC_QUOTE KC_NO    KC_NO    KC_LEFT KC_DOWN   KC_UP     KC_LBRACKET KC_RBRACKET   KC_BSLS
  KC_LSFT   KC_RABK KC_RCBR KC_RBRACKET KC_RPRN  KC_DQUO  KC_NO    KC_NO    KC_TILD KC_BSLASH KC_COMMA  KC_DOT      KC_RPRN  KC_RSFT
  RGB_RMOD  RGB_HUD RGB_SAD KC_LGUI     KC_BTN1  LOWER    KC_SPACE KC_ENTER RAISE   KC_BTN2   KC_HOME   KC_PGDOWN   KC_PGUP  KC_END
]
kbd.add_layer :lower, %i[
  KC_F1     KC_F2   $C_F3   KC_F4       KC_F5    KC_F6    KC_NO     KC_NO    KC_F7   KC_F8    KC_F9    KC_F10   KC_F11    KC_F12
  KC_ESCAPE KC_1    KC_2    KC_3        KC_4     KC_5     KC_NO     KC_NO    KC_6    KC_7     KC_8     KC_9     KC_0      KC_EQUAL
  KC_LCTL   KC_F2   KC_F10  KC_F12      KC_LPRN  KC_QUOTE KC_NO     KC_NO    KC_DOT  KC_4     KC_5     KC_6     KC_PLUS   KC_BSPACE
  KC_LSFT   KC_RABK KC_RCBR KC_RBRACKET KC_RPRN  KC_DQUO  KC_NO     KC_NO    KC_0    KC_1     KC_2     KC_3     KC_SLASH  KC_RSFT
  RGB_TOG   RGB_HUD RGB_SAD KC_LGUI     KC_BTN1  LOWER    KC_SPACE  KC_ENTER RAISE   KC_BTN2  KC_BTN3  RGB_SAI  RGB_HUI   RGB_TOG
]
kbd.define_mode_key :RAISE, [ nil, :raise, nil, nil ]
kbd.define_mode_key :LOWER, [ nil, :lower, nil, nil ]

rgb = RGB.new(0, 0, 32, false)
sleep 1
rgb.effect = :swirl
kbd.append rgb

def mm(*args)
  USB.merge_mouse_report(*args)
end

def mouse_cmd(kbd, wheel, xy, multi)
  accelerate = (kbd.layer.to_s == "lower") ? 2 : 10
  m = kbd.mouse
  ws = m.wheel_speed * multi * accelerate
  cs = m.cursor_speed * multi * accelerate
  if wheel
    if xy == :x
      mm(0, 0, 0, ws, 0)
    elsif xy == :y
      mm(0, 0, 0, 0, ws)
    end
  else
    if xy == :x
      mm(0, cs, 0, 0, 0)
    elsif xy == :y
      mm(0, 0, cs, 0, 0)
    end
  end
end

def raised?(kbd)
  kbd.layer.to_s == "raise"
end

# Initialize RotaryEncoder with pin_a and pin_b
encoder_left = RotaryEncoder.new(21, 9)
encoder_left.configure :left
# These implementations are still ad-hoc
encoder_left.clockwise do
  mouse_cmd(kbd, raised?(kbd), :y, 1)
end
encoder_left.counterclockwise do
  mouse_cmd(kbd, raised?(kbd), :y, -1)
end
kbd.append encoder_left

encoder_right = RotaryEncoder.new(21, 9)
encoder_right.configure :right
# These implementations are still ad-hoc
encoder_right.clockwise do
  mouse_cmd(kbd, raised?(kbd), :x, 1)
end
encoder_right.counterclockwise do
  mouse_cmd(kbd, raised?(kbd), :x, -1)
end
kbd.append encoder_right

kbd.append Mouse.new(driver: nil)

kbd.start!
