package com.sap.cx.swell.core.exceptions;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

import static java.lang.String.format;

@ResponseStatus(code = HttpStatus.UNPROCESSABLE_ENTITY)
public class InvalidDataException extends RuntimeException {

    public InvalidDataException(String message, Object... args) {
        super(format(message, args));
    }
}
