--We inherit from the original stuff and change two things:
--They have a death effect
--They have NicoIsRobot so they can repair each other
    if modApi.achievements:isComplete("Nico_Sent_weap","Nico_Bot_SWBB") then
        Nico_laserboom_mech = Nico_laserboom_mech:new{
            IsDeathEffect = true,
			NicoIsRobot = true,
        }
        Nico_artilleryboom_mech = Nico_artilleryboom_mech:new{
            IsDeathEffect = true,
			NicoIsRobot = true,
        }
        Nico_cannonboom_mech = Nico_cannonboom_mech:new{
            IsDeathEffect = true,
			NicoIsRobot = true,
        }
    end