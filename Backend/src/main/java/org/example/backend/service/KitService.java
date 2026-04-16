package org.example.backend.service;


import org.example.backend.Dto.KitDto;
import org.example.backend.model.Kit;
import org.example.backend.model.User;
import org.example.backend.repo.KitRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class KitService {

    @Autowired
    private KitRepo kitrepo;

    public Kit createKit(KitDto d){
        Kit kit = new Kit();
        User user = new User();
        kit.setName(d.getName());
        kit.setDescription(d.getDescription());
        kit.setPrice(d.getPrice());
        kit.setType(d.getType());
        kit.setMindset(d.getMindset());

        user.setId(d.getUserId());
        kit.setUser(user);

        return kitrepo.save(kit);
    }

    public Kit getKitById(int id){
        return kitrepo.findById(id).orElse(null);
    }

    public  Kit updateKit(int id , KitDto newKit){
        Kit oldKit = getKitById(id);

        if(oldKit == null)
            return null;

        oldKit.setName(newKit.getName());
        oldKit.setDescription(newKit.getDescription());
        oldKit.setPrice(newKit.getPrice());
        oldKit.setType(newKit.getType());
        oldKit.setMindset(newKit.getMindset());

        return kitrepo.save(oldKit);

    }

    public void deleteKit(int id){
        Kit removeKit = getKitById(id);
        kitrepo.delete(removeKit);
    }

    public List<Kit> getAllKits(){
        return kitrepo.findAll();
    }


}
