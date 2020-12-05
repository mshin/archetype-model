package com.github.mshin.archetype.model;

import java.io.Serializable;

import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * @author MunChul Shin
 */
@Data @AllArgsConstructor
public class DomainModel implements Serializable {

    private static final long serialVersionUID = -1937492209174401689L;

    private String field;

}
