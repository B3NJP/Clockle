player = {}
highscore = {}
bullets = {}
lasers = {}
enemies = {}
specials = {}
spebulls = {}
cleaners = {}
forcefields = {}


function Collision(x1, y1, w1, h1, x2, y2, w2, h2)
	-- body
	return x1 < x2 + w2 and
	x2 < x1 + w1 and
	y1 < y2 + h2 and
	y2 < y1 + h1
end


function love.load()
	highscore.file = io.open("Highscore", "r")
	if highscore.file:read() == "" then highscore.num = 0 else highscore.num = highscore.file:read() end
    player.img = love.graphics.newImage('assets/LaserShip.png')
    player.x = love.graphics.getWidth() / 2
	player.y = love.graphics.getHeight() - 50
	player.defaultSpeed = 400
	BulletImg = love.graphics.newImage('assets/Bullet.png')
	BulletSpeed = 250
	canShoot = true
	canShootTimerMax = 0.2
	canShootTimer = canShootTimerMax
	canShootSpeed = 1
	love.graphics.setBackgroundColor( 0, 0, 0 )
	EnemyImg = love.graphics.newImage('assets/Enemy.png')
	Enemy = true
	EnemySpeed = 120
	MakeEnemyMax = 0.6
	MakeEnemy = MakeEnemyMax
	MakeEnemySpeed = 2
	Score = 0
	Alive = false
	PewPew = love.audio.newSource("assets/gun-sound.wav")
	Hit = love.audio.newSource("assets/hit.wav")
	Death = love.audio.newSource("assets/death.wav")
	Lose = love.audio.newSource("assets/lose.wav")
	Start = false
	LaserImg = love.graphics.newImage('assets/laser.png')
	SpecialShoot = true
	LaserSpeed = 1000
	SpecialTimerMax = 10
	SpecialTimer = 0--SpecialTimerMax
	SpecialShootSpeed = 1
	Pause = false
	Pau = false
	SpecialImg = love.graphics.newImage('assets/special.png')
	SpecialSpeed = 80
	SpecialEnemyShootMax = 2
	SpecialEnemyShoot = 1
	Type = 0
	SpecialBulletImg = love.graphics.newImage('assets/Bullet.png')
	Overheat = 0
	OverheatSpeedDefault = 4
	Hot = false
	LoseIfEnd = false
	Mode = "Survivor"
	Changed = false
	Music = love.audio.newSource("assets/Music.mp3")
	Icon = love.graphics.newImage("assets/Icon.png")
	Go = 5
	PewPew:setVolume(0.5)
	Music:setLooping(true)
	Music:setVolume(0.1)
	love.audio.play(Music)
	Title = love.graphics.newImage("assets/Title.png")
	CleanerImg = love.graphics.newImage("assets/Cleaner.png")
	CleanerHealth = 20
	CleanerSpeed = EnemySpeed / 4
	Nm = 1
	IfBoss = true
	NumberOfBosses = 1
	Ship = 1
	ShipName = "Laser"
	ShipSpecial = "Laser"
	Ships = 3
	ForceSpeedDefault = 1
	ForceReset = 20
	Godmode = false
	ForcefieldIcon = love.graphics.newImage("assets/ForceField.png")
	ForcefieldTimerMax = 10
	shieldx = 0
	shieldy = 0
	AllControl = false
	res = false
	-- Not to be changed
	OverheatSpeed = OverheatSpeedDefault
	player.speed = player.defaultSpeed


end



function love.update(dt)
	Cheats()
	ShipChoice()
	GoTimer(dt)
	Modes()
	Buttons()		
	if not Pause then
		Starting()
		Slowmove(0.5)
		Movement(dt)
		Shooting()
		CopyClipboard()
		BulletTime(0.1)
		
		-----------------------------------------------------------------------------------------------------------------
		--Actual code----------------------------------------------------------------------------------------------------
		-----------------------------------------------------------------------------------------------------------------
		Forcefield()
		Timers(dt)

		

		if Score >= Nm * 100 and IfBoss then
			TypeOfBoss = math.random(1, NumberOfBosses)
			if TypeOfBoss == 1 then
	    		newBoss = { x = 0, y = 0, img = CleanerImg, health = CleanerHealth}
	    		table.insert(cleaners, newBoss)
	    		Nm = Nm + 1
	    	end
	    end

		if Enemy == true then
			Type = math.random( 10 )
			if Type <= 9 then
			newEnemy = { x = math.random(20, love.graphics.getWidth() - 20), y = 20, img = EnemyImg}
			table.insert(enemies, newEnemy)
		else
			newSpecial = { x = math.random(20, love.graphics.getWidth() - 20), y = 20, img = SpecialImg, rate = SpecialEnemyShootMax, ShootMax = SpecialEnemyShootMax, changed = false, m = math.random(1,3), move = true}
			table.insert(specials, newSpecial)
		end
			Enemy = false
			MakeEnemy = MakeEnemyMax
		end

	    if not love.keyboard.isDown('space') and not Hot then
	    	if Overheat > 0 then
	    		Overheat = Overheat - (OverheatSpeed * dt)
	    	end
	    end

	    if Hot then
	    	Overheat = Overheat - ((OverheatSpeed * dt) / 2)
	    end

	    if Overheat >= 20 then
	    	Hot = true
	    end

	    if Overheat > 20 then
	    	Overheat = 20
	    end

	    if Overheat <= 0 then
	    	Hot = false
	    end

	    if Overheat < 0 then
	    	Overheat = 0
	    end

	    for i, cleaner in ipairs(cleaners) do
	    	cleaner.y = cleaner.y + (CleanerSpeed * dt)
	    	if cleaner.y <= 0 then
	    		table.remove(cleaners, i)
	    	end
	    end

		for i, bullet in ipairs(bullets) do
			bullet.y = bullet.y - (BulletSpeed * dt)
	  		if bullet.y < 0 then -- remove bullets when they pass off the screen
				table.remove(bullets, i)
			end
		end

		for i, laser in ipairs(lasers) do
			laser.y = laser.y - (LaserSpeed * dt)
	  		if laser.y < 0 then -- remove bullets when they pass off the screen
				table.remove(laser, i)
			end
		end

		for i, enemy in ipairs(enemies) do
			enemy.y = enemy.y + (EnemySpeed * dt)
			if enemy.y > love.graphics.getHeight() then
				table.remove(enemies, i)
				if LoseIfEnd then
					if Alive then
						love.audio.play(Lose)
					end
					Alive = false
				end
			end
		end

		for i, cleaner in ipairs(cleaners) do
			if Collision(cleaner.x, cleaner.y, cleaner.img:getWidth(), cleaner.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight()) and Godmode == false then
				Alive = false
				love.audio.play(Death)
			end
			for l, bullet in ipairs(bullets) do
				if Collision(cleaner.x, cleaner.y, cleaner.img:getWidth(), cleaner.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
					cleaner.health = cleaner.health - 1
					table.remove(bullets, l)
					love.audio.play(Hit)
				end
			end
			for j, laser in ipairs(lasers) do
				if Collision(cleaner.x, cleaner.y, cleaner.img:getWidth(), cleaner.img:getHeight(), laser.x, laser.y, laser.img:getWidth(), laser.img:getHeight()) then
					cleaner.health = cleaner.health - 10
					table.remove(lasers, j)
					love.audio.play(Hit)
				end
			end
			if cleaner.health <= 0 then
				table.remove(cleaners, i)
				Score = Score + 30
				love.audio.play(Hit)
			end
		end

		for i, special in ipairs(specials) do
			if special.move then
				special.y = special.y + (SpecialSpeed * dt)
			end
			special.rate = special.rate - (SpecialEnemyShoot * dt)
			if player.x > special.x then
				special.x = special.x + (SpecialSpeedX * dt)
			end
			if player.x < special.x then
				special.x = special.x - (SpecialSpeedX * dt)
			end
			if special.y > love.graphics.getHeight()/4 and not special.changed then
				if special.m == 3 then
					special.ShootMax = special.ShootMax / 10
					special.move = false
				end
				special.changed = true
			end
			if special.rate < 0 then
				special.rate = special.ShootMax
				newSpebull = { x = special.x + special.img:getWidth() / 2 - 1, y = special.y + (special.img:getHeight()), img = SpecialBulletImg}
				table.insert(spebulls, newSpebull)
				love.audio.play(PewPew)
			end
			if special.y > love.graphics.getHeight() then
				table.remove(specials, i)
				if LoseIfEnd then
					if Alive then
						love.audio.play(Lose)
					end
					Alive = false
				end
			end
		end

		for i, spebull in ipairs(spebulls) do
			spebull.y = spebull.y + (BulletSpeed * dt)
	  		if spebull.y > love.graphics.getHeight() then -- remove bullets when they pass off the screen
				table.remove(spebulls, i)
			end
		end

		for i, enemy in ipairs(enemies) do
			for j, bullet in ipairs(bullets) do
				if Collision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
					love.audio.play(Hit)
					table.remove(bullets, j)
					table.remove(enemies, i)
					Score = Score + 1
				end
			end

			for l, laser in ipairs(lasers) do
				if Collision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), laser.x, laser.y, laser.img:getWidth(), laser.img:getHeight()) then
					love.audio.play(Hit)
					table.remove(enemies, i)
					Score = Score + 1
				end
			end

			if ForcefieldY then
				if Collision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), shieldx, shieldy, ForcefieldIcon:getWidth(), ForcefieldIcon:getHeight()) then
					table.remove(enemies, i)
					Score = Score + 1
				end
			end

			if Collision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight()) and Alive and not Godmode then
				table.remove(enemies, i)
				love.audio.play(Death)
				Alive = false
			end
	end

		for i, special in ipairs(specials) do
			if Collision(special.x, special.y, special.img:getWidth(), special.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight()) and Alive and not Godmode then
				love.audio.play(Death)
				table.remove(specials, i)
				Alive = false
			end
			for j, bullet in ipairs(bullets) do
				if Collision(special.x, special.y, special.img:getWidth(), special.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
					love.audio.play(Hit)
					table.remove(bullets, j)
					table.remove(specials, i)
					Score = Score + 2
				end
			end
			for l, laser in ipairs(lasers) do
				if Collision(special.x, special.y, special.img:getWidth(), special.img:getHeight(), laser.x, laser.y, laser.img:getWidth(), laser.img:getHeight()) then
					love.audio.play(Hit)
					table.remove(specials, i)
					Score = Score + 2
				end
			end
			if ForcefieldY then
				if Collision(special.x, special.y, special.img:getWidth(), special.img:getHeight(), shieldx, shieldy, ForcefieldIcon:getWidth(), ForcefieldIcon:getHeight()) then
					table.remove(specials, i)
					Score = Score + 1
				end
			end
		end

		for i, spebull in ipairs(spebulls) do
			if Collision(spebull.x, spebull.y, spebull.img:getWidth(), spebull.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight()) and Alive and not Godmode then
				love.audio.play(Death)
				table.remove(spebulls, i)
				Alive = false
			end
			for j, bullet in ipairs(bullets) do
				if Collision(spebull.x, spebull.y, spebull.img:getWidth(), spebull.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
					love.audio.play(Hit)
					table.remove(bullets, j)
					table.remove(spebulls, i)
				end
			end
			for l, laser in ipairs(lasers) do
				if Collision(spebull.x, spebull.y, spebull.img:getWidth(), spebull.img:getHeight(), laser.x, laser.y, laser.img:getWidth(), laser.img:getHeight()) then
					love.audio.play(Hit)
					table.remove(spebulls, i)
				end
			end
			if ForcefieldY then
				if Collision(spebull.x, spebull.y, spebull.img:getWidth(), spebull.img:getHeight(), shieldx, shieldy, ForcefieldIcon:getWidth(), ForcefieldIcon:getHeight()) then
					table.remove(spebulls, i)
				end
			end
		end
	end
	if love.keyboard.isDown('p') then
		Pau = true
	else
		Pau = false
	end
end



function love.draw()
	if Go > 0 then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(Icon, love.graphics.getWidth()/2 - Icon:getWidth()/2 * 10, 30, 0, 10, 10)
		love.graphics.draw(Title, love.graphics.getWidth()/2 - Title:getWidth()/2 * 10, 360, 0, 10, 10)
	else
	love.graphics.setBackgroundColor(255, 255, 255)
	love.graphics.setColor(0, 0, 0)

	for i, bullet in ipairs(bullets) do
  		love.graphics.draw(bullet.img, bullet.x, bullet.y)
	end

	for i, cleaner in ipairs(cleaners) do
		love.graphics.draw(cleaner.img, cleaner.x, cleaner.y, 0, 1, 1)
	end

	if ForcefieldY then
		love.graphics.draw(ForcefieldIcon, shieldx, shieldy)
	end

	for i, enemy in ipairs(enemies) do
		love.graphics.draw(enemy.img, enemy.x, enemy.y)
	end

	for i, laser in ipairs(lasers) do
		love.graphics.draw(laser.img, laser.x, laser.y)
	end

	for i, special in ipairs(specials) do
		love.graphics.draw(special.img, special.x, special.y)
	end

	for i, spebull in ipairs(spebulls) do
		love.graphics.draw(spebull.img, spebull.x, spebull.y)
	end

	if Alive then
		love.graphics.setColor(255, 255, 255)
    	love.graphics.draw(player.img, player.x, player.y, 0, 1, 1, 0, 0)
    	love.graphics.setColor(0, 0, 0)
    	love.graphics.print("Score: "..Score, love.graphics.getWidth() - 100, 10)
    	love.graphics.print("Highscore: "..Highscore.num, love.graphics.getWidth() - 100, 25)
    	if SpecialShoot then
			love.graphics.print(ShipSpecial.." is ready!", 10, 10)
		else
			love.graphics.print(ShipSpecial.." is not ready", 10, 10)
		end
		if Ship == 2 then
			if ForcefieldY == true then
				love.graphics.setColor(0, ((SpecialTimer-10)*10)*3, 0)
				love.graphics.rectangle('fill', 10, 25, ((SpecialTimer-10)*10)*2, 20)
			else
				love.graphics.setColor(0, (SpecialTimerMax - SpecialTimer) * 10, 0)
				love.graphics.rectangle('fill', 10, 25, ((SpecialTimerMax - 5) - SpecialTimer) * 10, 20)
			end
			love.graphics.setColor(0, 0, 0)
			love.graphics.rectangle('fill', (SpecialTimerMax - 5) * 10, 24, 10, 22)
		else
			love.graphics.setColor(0, (SpecialTimerMax - SpecialTimer) * 10, 0)
			love.graphics.rectangle('fill', 10, 25, (SpecialTimerMax - SpecialTimer) * 10, 20)
			love.graphics.setColor(0, 0, 0)
			love.graphics.rectangle('fill', SpecialTimerMax * 10, 24, 10, 22)
		end
		love.graphics.setColor(Overheat * 10, 0, 0)
		love.graphics.rectangle('fill', 10, 50, Overheat * 10, 20)
	else
		love.graphics.setColor(0, 0, 0)
		if Start then
			love.graphics.print("You died. Press 'R' to restart. Your score was: "..Score..", Your highscore was: "..highscore.num, love.graphics:getWidth()/2-65, love.graphics:getHeight()/2-10)
			love.graphics.print("Press 'C' to copy to clipboard", love.graphics:getWidth()/2-65, love.graphics:getHeight()/2+5)
			love.graphics.print("Press 'T' for toggle: "..Mode, love.graphics:getWidth()/2-65, love.graphics:getHeight()/2+20)
			love.graphics.print("Press 'S' to change ship: "..ShipName, love.graphics.getWidth()/2-65, love.graphics:getHeight()/2+35)
		else
			love.graphics.print("Press 'Space' to start", love.graphics:getWidth()/2-65, love.graphics:getHeight()/2-10)
			love.graphics.print("Press 'T' for toggle: "..Mode, love.graphics:getWidth()/2-65, love.graphics:getHeight()/2+5)
			love.graphics.print("Press 'S' to change ship: "..ShipName, love.graphics.getWidth()/2-65, love.graphics:getHeight()/2+20)
		end
	end
end
end

function Cheats()
	-- Totally Nothing \/
	if love.keyboard.isDown('l') and love.keyboard.isDown('u') and love.keyboard.isDown('p') and love.keyboard.isDown('a') then
		Godmode = true
	end
	-- Totally Nothing /\

	-- Totally Nothing \/
	if love.keyboard.isDown('c') and love.keyboard.isDown('t') and love.keyboard.isDown('r') and love.keyboard.isDown('l') then
		AllControl = true
	end
	-- Totally Nothing /\
end

function ShipChoice()
	if Ship == 1 then
		player.img = love.graphics.newImage('assets/LaserShip.png')
		ShipName = "Laser"
		ShipSpecial = "Laser"
		SpecialTimerMax = 10
	end

	if Ship == 2 then
		player.img = love.graphics.newImage('assets/ForceShip.png')
		ShipName = "Force"
		ShipSpecial = "Forcefield"
		SpecialTimerMax = 15
	end
	if Ship == 3 then
		player.img = love.graphics.newImage('assets/StealthShip.png')
		ShipName = "Stealth"
		ShipSpecial = "Teleport"
		SpecialTimerMax = 5
	end
end

function GoTimer(dt)
	if Go > 0 then
		Go = (Go - 1 * dt)
	end
end

function Modes()
	if Mode == "Survivor" then
		OverheatSpeedDefault = 4
		MakeEnemyMax = 0.4
		LoseIfEnd = false
		IfBoss = true
	end

	if Mode == "Defender" then
		OverheatSpeedDefault = 8
		MakeEnemyMax = 1.0
		LoseIfEnd = true
		IfBoss = false
	end
end

function Buttons()
	if love.keyboard.isDown('t') and not Alive and not Changed then
		if Mode == "Survivor" then
			Mode = "Defender"
		elseif Mode == "Defender" then
			Mode = "Survivor"
		end
		Changed = true
	end

	if love.keyboard.isDown('s') and not Alive and not Changed then
		Changed = true
		if Ship < Ships then
			Ship = Ship + 1
		else
			Ship = 1
		end
	end

	if love.keyboard.isDown('m') and not Alive and not Changed then
		Changed = true
		if defaultSpeed == 300 then
			defaultSpeed = 400
		else
			defaultSpeed = 300
		end
	end

	if not love.keyboard.isDown('t') and not love.keyboard.isDown('s') and not love.keyboard.isDown('m') then
		Changed = false
	end

	if not Alive then
		bullets = {}
	end

	if love.keyboard.isDown('p') then
		if not Pau then
			if Pause then
				Pause = false
			else
				Pause = true
			end
		end
	end
end

function Starting()
	if not Alive and Start and love.keyboard.isDown('r') and not res then
		if Score > highscore.num then
			highscore.num = Score
			highscore.file:close()
			highscore.file = io.open("Highscore", "w+")
			highscore.file:write(highscore.num)
		end
		bullets = {}
		enemies = {}
		lasers = {}
		specials = {}
		spebulls = {}
		cleaners = {}
		canShootTimer = canShootTimerMax
		createEnemyTimer = createEnemyTimerMax
		player.x = love.graphics.getWidth() / 2
		player.y = love.graphics.getHeight() - 50
		Score = 0
		Alive = true
		canShoot = true
		SpecialShoot = true
		Overheat = 0
		Hot = false
		Nm = 1
		res = true
		Godmode = false
		AllControl = false
		SpecialTimer = 0
	end
	if not Alive and not Start and love.keyboard.isDown('space') then
		bullets = {}
		enemies = {}
		lasers = {}
		specials = {}
		spebulls = {}
		cleaners = {}
		canShootTimer = canShootTimerMax
		createEnemyTimer = createEnemyTimerMax
		player.x = love.graphics.getWidth() / 2
		player.y = love.graphics.getHeight() - 50
		Score = 0
		Alive = true
		if Start == false then
			Start = true
		end
		canShoot = true
		SpecialShoot = true
		Overheat = 0
		Hot = false
		Nm = 1
		SpecialTimer = 0
	end
	if Alive and love.keyboard.isDown('r') and not res and not love.keyboard.isDown('c') then
		Alive = false
		res = true
	end
	if love.keyboard.isDown('r') then
	else
		res = false
	end
end

function Movement(dt)
	if love.keyboard.isDown('right') then
		if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
			player.x = player.x + (player.speed * dt)
		end
	end

	if love.keyboard.isDown('down') then
		if AllControl then
			if player.y < (love.graphics.getHeight() - player.img:getHeight()) then
				player.y = player.y + (player.speed * dt)
			end
		end
	end

	if love.keyboard.isDown('up') then
		if AllControl then
			if player.y > 0 then
				player.y = player.y - (player.speed * dt)
			end
		end
	end

	if love.keyboard.isDown('left') then
		if player.x > 0 then
			player.x = player.x - (player.speed * dt)
		end
	end

	if love.keyboard.isDown('space') or love.keyboard.isDown('v') then
		player.speed = player.defaultSpeed * 0.4
	else
		player.speed = player.defaultSpeed
	end
end

function Shooting()
	if love.keyboard.isDown('space') and canShoot and Alive and not Hot then
		newBullet = { x = player.x + player.img:getWidth() / 2, y = player.y - (player.img:getHeight()), img = BulletImg}
		table.insert(bullets, newBullet)
		love.audio.play(PewPew)
		canShoot = false
		canShootTimer = canShootTimerMax
		Overheat = Overheat + 1
	end

	if love.keyboard.isDown('v') and SpecialShoot and Alive and Ship == 1 then
		newLaser = { x = player.x + player.img:getWidth() / 2 - 5, y = player.y - (player.img:getHeight()), img = LaserImg}
		table.insert(lasers, newLaser)
		love.audio.play(PewPew)
		SpecialShoot = false
		SpecialTimer = SpecialTimerMax
	end

	if love.keyboard.isDown('v') and SpecialShoot and Alive and Ship == 2 then
		shieldx = player.x + player.img:getWidth()/2 - ForcefieldIcon:getWidth()/2
		shieldy = player.y + player.img:getHeight()/2 - ForcefieldIcon:getHeight()/2
		ForcefieldY = true
		SpecialShoot = false
		SpecialTimer = SpecialTimerMax
	end

	if love.keyboard.isDown('v') and SpecialShoot and Alive and Ship == 3 then
		player.x = love.mouse.getX()
		SpecialShoot = false
		SpecialTimer = SpecialTimerMax
	end
end

function CopyClipboard()
	if not Alive and Start then
		if love.keyboard.isDown('c') then
			love.system.setClipboardText(Score)
		end
	end
end

function BulletTime(multiplier)
	if love.keyboard.isDown('v') or love.keyboard.isDown('space') or love.keyboard.isDown('left') or love.keyboard.isDown('right') or love.keyboard.isDown('up') or love.keyboard.isDown('down') then
		MakeEnemySpeed = 2
		EnemySpeed = 120
		canShootSpeed = 1
		BulletSpeed = 250
		LaserSpeed = 1000
		SpecialShootSpeed = 1
		SpecialSpeed = 80
		SpecialEnemyShoot = 1
		OverheatSpeed = OverheatSpeedDefault
		SpecialSpeedX = 20
		CleanerSpeed = EnemySpeed / 4
	else
		MakeEnemySpeed = 2 * multiplier
		EnemySpeed = 120 * multiplier
		canShootSpeed = 1 * multiplier
		BulletSpeed = 250 * multiplier
		LaserSpeed = 1000 * multiplier
		SpecialShootSpeed = 1 * multiplier
		SpecialSpeed = 80 * multiplier
		SpecialEnemyShoot = 1 * multiplier
		OverheatSpeed = OverheatSpeedDefault * multiplier
		SpecialSpeedX = 20 * multiplier
		CleanerSpeed = EnemySpeed / 4
	end
end

function Slowmove(multiplier)
	if love.keyboard.isDown('lshift') then
		player.speed = player.defaultSpeed * multiplier
	else
		player.speed = player.defaultSpeed
	end
end

function Forcefield()
	if ForcefieldY then
		shieldx = player.x + player.img:getWidth()/2 - ForcefieldIcon:getWidth()/2
		shieldy = player.y + player.img:getHeight()/2 - ForcefieldIcon:getHeight()/2
	end

	if ForcefieldTimerMax > SpecialTimer then
		ForcefieldY = false
	end
end

function Timers(dt)
	MakeEnemy = MakeEnemy - (MakeEnemySpeed * dt)
	if MakeEnemy < 0 then
		Enemy = true
	end

	canShootTimer = canShootTimer - (canShootSpeed * dt)
	if canShootTimer < 0 then
		canShoot = true
	end

	if SpecialTimer > 0 then
		SpecialTimer = SpecialTimer - (SpecialShootSpeed * dt)
	end
	if SpecialTimer < 0 then
		SpecialShoot = true
	end
end






