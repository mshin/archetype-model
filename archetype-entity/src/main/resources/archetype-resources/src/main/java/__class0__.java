package ${package};

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Convert;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 
 * For lazy initialized fields, exclude from the toString.
 * @ToString.Exclude @Getter(lazy = true)
 * 
 * Do not add generated id to hashCode. https://hibernate.atlassian.net/browse/HHH-3799
 * @Id @EqualsAndHashCode.Exclude
 * 
 * 
 * 
 * @author ${author}
 */
@Data
@NoArgsConstructor
@Entity
@Table( name = "entity_name" )
public class ${class0} {

    ${fields}

}
