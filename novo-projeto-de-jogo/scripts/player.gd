extends CharacterBody2D

const SPEED = 200.0
const JUMP_FORCE = -370.0

var is_jumping := false
var is_attacking := false

@onready var animation = $Anim as AnimatedSprite2D
@onready var attack_timer = Timer.new() # Criação do temporizador para parar o ataque do personagem

func _ready() -> void:
	# Adicionar o temporizador como um nó filho do personagem
	add_child(attack_timer)
	attack_timer.wait_time = 0.5  # Duração do ataque em segundos
	attack_timer.one_shot = true
	attack_timer.connect("timeout", Callable(self, "_on_attack_finished"))


func _physics_process(delta: float) -> void:
	# Adiciona gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Lidar com o salto.
	if Input.is_action_just_pressed("ui_up") and is_on_floor() and not is_attacking:
		velocity.y = JUMP_FORCE
		is_jumping = true
	elif is_on_floor() and not is_attacking:
		is_jumping = false

	# Checando se esta atacando
	if Input.is_action_just_pressed("attack") and not is_attacking:
		perform_attack()
	
	# Lidar com o movimento se não estiver atacando
	if not is_attacking:
		handle_movement()

	move_and_slide()


func handle_movement() -> void:
	# Obtenha a direção de entrada e controle o movimento/desaceleração.
	var direction := Input.get_axis("ui_left", "ui_right")
	
	# Dá Prioridade a animação de pulo do personagem
	if is_jumping and not is_attacking:
		animation.play("jump")
	elif direction != 0:
		velocity.x = direction * SPEED
		animation.scale.x = direction
		if is_on_floor() and not is_jumping: # executa a animação de corrida quando está no chão 
			animation.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor() and not is_jumping:  # Só tem Idle quando está no chão
			animation.play("Idle")


func perform_attack() -> void:
	is_attacking = true
	animation.play("punch")
	
	# inicia o temporizador do ataque
	attack_timer.start()


func _on_attack_finished() -> void:
	is_attacking = false
	animation.play("Idle")  # volta a animaçao Idle quando a animaçao de ataque termina
