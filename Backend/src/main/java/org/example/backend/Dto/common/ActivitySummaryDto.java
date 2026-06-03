package org.example.backend.Dto.common;

import lombok.Data;
import org.example.backend.model.activity.Activity;
import org.example.backend.util.enums.Type;

@Data
public class ActivitySummaryDto {
    private int id;
    private String name;
    private Type type;
    private String description;
    private String coverImageKey;
    private String coverImageUrl;
    private Boolean voiceEnabled;
    private Integer kitId;

    public static ActivitySummaryDto from(Activity activity) {
        return from(activity, null);
    }

    public static ActivitySummaryDto from(Activity activity, String coverImageUrl) {
        if (activity == null) return null;
        ActivitySummaryDto dto = new ActivitySummaryDto();
        dto.setId(activity.getId());
        dto.setName(activity.getName());
        dto.setType(activity.getType());
        dto.setDescription(activity.getDescription());
        dto.setCoverImageKey(activity.getCoverImageKey());
        dto.setCoverImageUrl(coverImageUrl);
        dto.setVoiceEnabled(activity.getVoiceEnabled());
        dto.setKitId(activity.getKit() != null ? activity.getKit().getId() : null);
        return dto;
    }
}
