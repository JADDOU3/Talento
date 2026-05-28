package org.example.backend.Dto.activity;

import lombok.Data;
import org.example.backend.model.Kit;
import org.example.backend.model.activity.Activity;
import org.example.backend.util.enums.Type;

@Data
public class ActivityResponseDto {
    private int id;
    private String name;
    private Type type;
    private String description;
    private String gameDescription;
    private String coverImageKey;
    private String coverImageUrl;
    private Boolean voiceEnabled;
    private Kit kit;

    public ActivityResponseDto(Activity activity, String coverImageUrl) {
        this.id = activity.getId();
        this.name = activity.getName();
        this.type = activity.getType();
        this.description = activity.getDescription();
        this.gameDescription = activity.getGameDescription();
        this.coverImageKey = activity.getCoverImageKey();
        this.coverImageUrl = coverImageUrl;
        this.voiceEnabled = activity.getVoiceEnabled();
        this.kit = activity.getKit();
    }
}