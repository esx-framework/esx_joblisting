local menuIsShowed, TextUIdrawing = false, false

function ShowJobListingMenu()
  menuIsShowed = true
  ESX.TriggerServerCallback('esx_joblisting:getJobsList', function(jobs)
    local elements = {{unselectable = "true", title = TranslateCap('job_center'), icon = "fas fa-briefcase"}}

    for i = 1, #(jobs) do
      elements[#elements + 1] = {title = jobs[i].label, name = jobs[i].name}
    end

    ESX.OpenContext("right", elements, function(menu, SelectJob)
      TriggerServerEvent('esx_joblisting:setJob', SelectJob.name)
      ESX.CloseContext()
      ESX.ShowNotification(TranslateCap('new_job', SelectJob.title), "success")
      menuIsShowed = false
      TextUIdrawing = false
    end, function()
      menuIsShowed = false
      TextUIdrawing = false
    end)
  end)
end

CreateThread(function()
  while not ESX.PlayerLoaded do 
    Wait(0)
  end

  for i = 1, #Config.Zones, 1 do
    -- Blips 
    if Config.Blip.Enabled then
      local blip = AddBlipForCoord(Config.Zones[i])

      SetBlipSprite(blip, Config.Blip.Sprite)
      SetBlipDisplay(blip, Config.Blip.Display)
      SetBlipScale(blip, Config.Blip.Scale)
      SetBlipColour(blip, Config.Blip.Colour)
      SetBlipAsShortRange(blip, Config.Blip.ShortRange)

      BeginTextCommandSetBlipName("STRING")
      AddTextComponentSubstringPlayerName(TranslateCap('blip_text'))
      EndTextCommandSetBlipName(blip)
    end

    -- Markers
    ESX.CreateMarker("joblist", Config.Zones[i], Config.DrawDistance, TranslateCap("access_job_center"), {
      drawMarker = true,
      key = 38,
       scale = Config.ZoneSize, -- Scale of the marker
       sprite = Config.MarkerType, -- type of the marker
       colour =  Config.MarkerColor -- R, G, B, A, colour system
    }, function()
        if not menuIsShowed then
          ShowJobListingMenu()
          ESX.HideUI()
        end
    end)
  end
end)
