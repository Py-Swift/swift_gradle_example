// Stub annotation for Android
package org.swift.swiftkit.core.annotations;

import java.lang.annotation.*;

/**
 * Indicates that the annotated element can be null.
 */
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.FIELD, ElementType.PARAMETER, ElementType.METHOD, ElementType.TYPE_USE, ElementType.LOCAL_VARIABLE})
public @interface Nullable {
}
