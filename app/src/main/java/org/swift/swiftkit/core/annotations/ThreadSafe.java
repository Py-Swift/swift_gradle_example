// Stub annotation for Android (jdk.jfr not available)
package org.swift.swiftkit.core.annotations;

import java.lang.annotation.*;

/**
 * Indicates that the annotated element represents a thread-safe value.
 * Stub for Android compatibility (original uses jdk.jfr annotations).
 */
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.FIELD, ElementType.PARAMETER, ElementType.METHOD, ElementType.TYPE_USE})
public @interface ThreadSafe {
}
